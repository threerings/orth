package com.threerings.orth.aether.server;

import static com.threerings.orth.Log.log;

import java.util.List;
import java.util.Map;

import com.google.common.collect.HashMultimap;
import com.google.common.collect.Lists;
import com.google.common.collect.SetMultimap;
import com.google.inject.Inject;
import com.google.inject.Injector;
import com.google.inject.Singleton;

import com.samskivert.util.Invoker;
import com.samskivert.util.Lifecycle;

import com.threerings.orth.aether.data.AetherCodes;
import com.threerings.orth.aether.data.FriendMarshaller;
import com.threerings.orth.aether.data.PlayerName;
import com.threerings.orth.aether.data.PlayerObject;
import com.threerings.orth.aether.server.persist.RelationshipRepository;
import com.threerings.orth.data.FriendEntry;
import com.threerings.orth.data.OrthCodes;
import com.threerings.orth.notify.data.FriendInviteNotification;
import com.threerings.orth.peer.data.OrthClientInfo;
import com.threerings.orth.peer.server.OrthPeerManager;
import com.threerings.orth.server.persist.OrthPlayerRepository;
import com.threerings.presents.annotation.MainInvoker;
import com.threerings.presents.client.InvocationService.InvocationListener;
import com.threerings.presents.client.InvocationService.ResultListener;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.dobj.DSet;
import com.threerings.presents.peer.server.NodeRequestsListener;
import com.threerings.presents.server.InvocationException;
import com.threerings.presents.server.InvocationManager;
import com.threerings.presents.server.PresentsSession;
import com.threerings.util.Resulting;

/**
 * Manages {@link PlayerObject#friends} and friend-related request for the local server.
 */
@Singleton
public class FriendManager implements Lifecycle.InitComponent, FriendProvider
{
    @Inject public FriendManager (Injector injector)
    {
        injector.getInstance(Lifecycle.class).addComponent(this);

        // register our bootstrap invocation service
        injector.getInstance(InvocationManager.class).registerProvider(
            this, FriendMarshaller.class, OrthCodes.AETHER_GROUP);
    }

    @Override
    public void init ()
    {
        _locator.addObserver(new PlayerSessionLocator.Observer() {
            @Override public void playerLoggedIn (PresentsSession session, PlayerObject plobj) {
                initFriends(plobj);
            }

            @Override public void playerWillLogout (PresentsSession session, PlayerObject plobj) {
                shutdownFriends(plobj);
            }
        });
        _aetherMgr.addObserver(new OrthPeerManager.FarSeeingObserver<PlayerName>() {
            @Override public void loggedOn (String node, PlayerName member) {
                notifyFriends(member.getId(), FriendEntry.Status.ONLINE);
            }
            @Override public void loggedOff (String node, PlayerName member) {
                notifyFriends(member.getId(), FriendEntry.Status.OFFLINE);
            }
        });
    }

    public void requestFriendship (ClientObject caller, final int targetId,
        InvocationListener listener)
        throws InvocationException
    {
        PlayerObject player = (PlayerObject)caller;

        // anti-spam logic
        final Map<Integer, Long> pending = player.getLocal(PlayerLocal.class).pendingFriendRequests;
        Long lastRequest = pending.get(targetId);
        long now = System.currentTimeMillis();
        if (lastRequest != null && now - lastRequest < MIN_FRIEND_REQUEST_PERIOD) {
            throw new InvocationException(AetherCodes.FRIEND_REQUEST_ALREADY_SENT);
        }
        pending.put(targetId, now);

        // ok, notify the other player, wherever they are
        _requests.sendNotification(targetId, new FriendInviteNotification(player.getPlayerName()),
                new Resulting<Void>(listener) {
            @Override public void requestFailed (Exception cause) {
                pending.remove(targetId);
                super.requestFailed(cause);
            }
        });
    }

    public void acceptFriendshipRequest (
        ClientObject caller, final int senderId, final InvocationListener listener)
        throws InvocationException
    {
        final PlayerObject acceptingPlayer = (PlayerObject)caller;
        final int acceptingPlayerId = acceptingPlayer.getPlayerId();

        // forward this acceptance to the server the other player is on
        _peerMgr.invokeNodeRequest(new PlayerNodeRequest(senderId) {
            @Inject transient OrthPeerManager peermgr;
            @Inject transient FriendManager friendmgr;
            @Override protected void execute (PlayerObject sender, ResultListener listener) {
                PlayerLocal local = sender.getLocal(PlayerLocal.class);
                if (local.pendingFriendRequests.remove(acceptingPlayerId) == null) {
                    log.warning("Uninvited friend acceptance!", "playerId", acceptingPlayerId,
                        "sender", _targetPlayer);
                    listener.requestFailed(AetherCodes.INTERNAL_ERROR);
                    return;
                }

                // add the friend!
                OrthClientInfo other = peermgr.locatePlayer(acceptingPlayerId);
                if (other == null) {
                    log.warning("Edge case, accepting friend logged off before sender received " +
                        "notification of friendship", "senderId", senderId,
                        "acceptingPlayerId", acceptingPlayerId);
                } else {
                    friendmgr.addNewFriend(sender, other);
                }

                // finished, go back to the original peer
                listener.requestProcessed(null);
            }
        }, new NodeRequestsListener<Void>() {
            @Override public void requestsProcessed (NodeRequestsResult<Void> result) {
                // all clear, add the friend!
                addNewFriend(acceptingPlayer, _peerMgr.locatePlayer(senderId));

                // persist: friends4evah
                _invoker.postRunnable(new Runnable() {
                   @Override public void run () {
                       _friendRepo.addFriendship(acceptingPlayerId, senderId);
                   }
                   @Override public String toString () {
                       return "Add friends";
                   }
                });
            }
            @Override public void requestFailed (String cause) {
                listener.requestFailed(cause);
            }
        });
    }

    /**
     * Sets up the members friends and adds to friend tracking.
     */
    protected void initFriends (final PlayerObject player)
    {
        log.debug("Strarting resolution of friends dset", "player", player);

        if (!player.friends.isEmpty()) {
            log.warning("Friends already? Something is very wrong.", "player", player.who());
            return;
        }

        final PlayerLocal local = player.getLocal(PlayerLocal.class);
        final List<FriendEntry> friends = Lists.newArrayListWithCapacity(
            local.unresolvedFriendIds.size());
        for (Integer friendId : local.unresolvedFriendIds) {
            OrthClientInfo clientInfo = _peerMgr.locatePlayer(friendId);
            if (clientInfo != null) {
                friends.add(toFriendEntry(clientInfo));
                local.unresolvedFriendIds.remove(friendId);
            }
        }

        if (local.unresolvedFriendIds.isEmpty()) {
            updateFriends(player, friends);
            return;
        }

        // now we need to load the names for offline friends
        _invoker.postUnit(new Resulting<Map<Integer, String>>("Load offline friend names") {
            @Override public Map<Integer, String> invokePersist () throws Exception {
                // if this fails, we will be in a pretty bad state
                return _playerRepo.resolvePlayerNames(local.unresolvedFriendIds);
            }

            @Override public void requestCompleted (Map<Integer, String> result) {
                if (!player.isActive()) {
                    log.info("Player logged off prior to getting friends. Sad.",
                        "player", player.who());
                    return;
                }

                for (Map.Entry<Integer, String> pair : result.entrySet()) {
                    friends.add(FriendEntry.offline(pair.getKey(), pair.getValue()));
                }
                updateFriends(player, friends);
            }
        });
    }

    protected void updateFriends (PlayerObject player, List<FriendEntry> friends)
    {
        // the player may have had some friends come online already while we were off in invoker
        // land. Replace the ones in the invoker list since the status should be more up to
        for (FriendEntry entry : player.friends) {
            friends.remove(entry.getKey()); // out with the resolved
            friends.add(entry); // in with the recently online
        }

        // set up the reverse listening map
        for (FriendEntry entry : friends) {
            _notifyMap.put(entry.name.getId(), player);
        }

        // set the friends
        player.setFriends(DSet.newDSet(friends));

        // clear out the holding buffer
        player.getLocal(PlayerLocal.class).unresolvedFriendIds = null;

        log.debug("Finished resolution of friends dset", "player", player);
    }

    protected void shutdownFriends (PlayerObject player)
    {
        log.debug("Removing friend notifications", "player", player);

        for (FriendEntry entry : player.friends) {
            _notifyMap.remove(entry.name.getId(), player);
        }
    }

    protected void notifyFriends (int playerId, FriendEntry.Status status)
    {
        log.debug("Notifying friends", "playerId", playerId, "status", status);

//CWG-JD Why manually box this? For efficiency? The JVM will take care of that for you.
//JD-CWG Yes... I didn't know the JVM would figure out that playerId doesn't change. Do I need
//to mark it final to take advantage of the optim?
        Integer boxedPlayerId = playerId;
        for (PlayerObject friend : _notifyMap.get(playerId)) {
            FriendEntry entry = friend.friends.get(boxedPlayerId);
            if (entry == null) {
                continue;
            }
            entry = entry.clone();
            entry.status = status;
            friend.updateFriends(entry);
        }
    }

    protected void addNewFriend (PlayerObject player, OrthClientInfo other)
    {
        if (other == null) {
            return;
        }
        player.addToFriends(toFriendEntry(other));
        _notifyMap.put(other.playerName.getId(), player);
    }

    protected static FriendEntry toFriendEntry (OrthClientInfo info)
    {
        return FriendEntry.fromPlayerName(info.playerName, FriendEntry.Status.ONLINE);
    }

    /** Mapping of local and remote player ids to friend ids logged into this server. */
    protected SetMultimap<Integer, PlayerObject> _notifyMap = HashMultimap.create();

    // dependencies
    @Inject protected AetherManager _aetherMgr;
    @Inject protected PlayerSessionLocator _locator;
    @Inject protected OrthPeerManager _peerMgr;
    @Inject protected OrthPlayerRepository _playerRepo;
    @Inject protected RelationshipRepository _friendRepo;
    @Inject protected @MainInvoker Invoker _invoker;
    @Inject protected PlayerNodeRequests _requests;

    protected static final long MIN_FRIEND_REQUEST_PERIOD = 60 * 1000L;
}
