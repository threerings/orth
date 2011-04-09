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
import com.threerings.orth.aether.data.PlayerName;
import com.threerings.orth.aether.data.PlayerObject;
import com.threerings.orth.aether.server.persist.RelationshipRepository;
import com.threerings.orth.data.FriendEntry;
import com.threerings.orth.notify.data.FriendInviteNotification;
import com.threerings.orth.notify.server.NotificationManager;
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
import com.threerings.presents.server.PresentsSession;
import com.threerings.util.Resulting;

/**
 * Manages {@link PlayerObject#friends} and friend-related request for the local server.
 */
@Singleton
public class FriendManager implements Lifecycle.InitComponent
{
    @Inject public FriendManager (Injector injector)
    {
        injector.getInstance(Lifecycle.class).addComponent(this);
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
        final InvocationListener listener)
        throws InvocationException
    {
        final PlayerObject player = (PlayerObject)caller;

        // anti-spam logic
        final Map<Integer, Long> pending = player.getLocal(PlayerLocal.class).pendingFriendRequests;
        Long lastRequest = pending.get(targetId);
        long now = System.currentTimeMillis();
        if (lastRequest != null && now - lastRequest < MIN_FRIEND_REQUEST_PERIOD) {
            throw new InvocationException(AetherCodes.FRIEND_REQUEST_ALREADY_SENT);
        }
        pending.put(targetId, now);

        // ok, notify the other player, wherever they are
        _peermgr.invokeNodeRequest(new PlayerNodeRequest(targetId) {
            @Inject transient NotificationManager notMgr;
            @Override protected void execute (PlayerObject target, ResultListener listener) {
                notMgr.notify(target, new FriendInviteNotification(player.getPlayerName()));
                listener.requestProcessed(null);
            }
        }, new NodeRequestsListener<Void>() {
            @Override public void requestsProcessed (NodeRequestsResult<Void> result) {
            }
            @Override public void requestFailed (String cause) {
                pending.remove(targetId);
                listener.requestFailed(cause);
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
        _peermgr.invokeNodeRequest(new PlayerNodeRequest(senderId) {
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
                addNewFriend(acceptingPlayer, _peermgr.locatePlayer(senderId));

                // persist: friends4evah
                _invoker.postRunnable(new Runnable() {
                   @Override public void run () {
                       _friendrepo.addFriendship(acceptingPlayerId, senderId);
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

//CWG-JD I just added DSet.isEmpty to match collections and make code like this a little cleaner
        if (player.friends.size() != 0) {
            log.warning("Friends already? Something is very wrong.", "player", player.who());
            return;
        }

        final PlayerLocal local = player.getLocal(PlayerLocal.class);
        final List<FriendEntry> friends = Lists.newArrayListWithCapacity(
            local.unresolvedFriendIds.size());
        for (Integer friendId : local.unresolvedFriendIds) {
            OrthClientInfo clientInfo = _peermgr.locatePlayer(friendId);
            if (clientInfo != null) {
                friends.add(toFriendEntry(clientInfo));
                local.unresolvedFriendIds.remove(friendId);
            }
        }

        if (local.unresolvedFriendIds.size() == 0) {
            initFriends2(player, friends);
            return;
        }

        // now we need to load the names for offline friends
        _invoker.postUnit(new Resulting<Map<Integer, String>>("Load offline friend names") {
            @Override public Map<Integer, String> invokePersist () throws Exception {
                // if this fails, we will be in a pretty bad state
                return _playerrepo.resolvePlayerNames(local.unresolvedFriendIds);
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
                initFriends2(player, friends);
            }
        });
    }

//CWG-JD I'm not a big fan of numerically increasing names for staggered operations like this. It
//doesn't tell you anything about what the split up methods do. initFriends could be resolveFriends
//and this method could be publishResolvedFriends or something like that.
    protected void initFriends2 (PlayerObject player, List<FriendEntry> friends)
    {
        // the player may have had some friends come online already, replace the ones in our list
        // this is inefficient but very very rare
        for (FriendEntry entry : player.friends) {
//CWG-JD This replaces an existing entry instance with an offline status with a new one with an
//online status? If so, it could use documentation of that. Calling remove and then add with the
//same object looks kinda insane :)
            friends.remove(entry);
            friends.add(entry);
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
//CWG-JD We're camel-case people on who, so _peerMgr, _playerRepo, and _friendRepo.
    @Inject protected OrthPeerManager _peermgr;
    @Inject protected OrthPlayerRepository _playerrepo;
    @Inject protected RelationshipRepository _friendrepo;
    @Inject protected @MainInvoker Invoker _invoker;

    protected static final long MIN_FRIEND_REQUEST_PERIOD = 60 * 1000L;
}
