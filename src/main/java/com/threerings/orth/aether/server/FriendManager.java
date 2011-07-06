//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.aether.server;

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

import com.threerings.util.Resulting;

import com.threerings.presents.annotation.MainInvoker;
import com.threerings.presents.client.InvocationService.InvocationListener;
import com.threerings.presents.client.InvocationService.ResultListener;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.dobj.DSet;
import com.threerings.presents.peer.server.NodeRequestsListener;
import com.threerings.presents.server.InvocationException;
import com.threerings.presents.server.InvocationManager;
import com.threerings.presents.server.PresentsSession;

import com.threerings.orth.aether.data.AetherCodes;
import com.threerings.orth.aether.data.FriendMarshaller;
import com.threerings.orth.aether.data.FriendshipAcceptance;
import com.threerings.orth.aether.data.FriendshipRequest;
import com.threerings.orth.aether.data.AetherClientObject;
import com.threerings.orth.aether.server.persist.RelationshipRepository;
import com.threerings.orth.comms.data.CommSender;
import com.threerings.orth.data.FriendEntry;
import com.threerings.orth.data.OrthCodes;
import com.threerings.orth.data.PlayerName;
import com.threerings.orth.peer.data.OrthClientInfo;
import com.threerings.orth.peer.server.OrthPeerManager;
import com.threerings.orth.server.persist.PlayerRepository;
import com.threerings.orth.server.util.InviteThrottle;

import static com.threerings.orth.Log.log;

/**
 * Manages {@link AetherClientObject#friends} and friend-related request for the local server.
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
            @Override public void playerLoggedIn (PresentsSession session, AetherClientObject plobj) {
                initFriends(plobj);
            }

            @Override public void playerWillLogout (PresentsSession session, AetherClientObject plobj) {
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

    public void requestFriendship (final ClientObject caller, final int targetId,
        InvocationListener listener)
        throws InvocationException
    {
        AetherClientObject player = ((AetherClientObject)caller);
        final PlayerName playerName = player.playerName;

        // anti-spam logic
        final InviteThrottle throttle = player.getLocal(PlayerLocal.class).getInviteThrottle();
        if (!throttle.allow(targetId)) {
            throw new InvocationException(AetherCodes.FRIEND_REQUEST_ALREADY_SENT);
        }

        // ok, notify the other player, wherever they are
        _peerMgr.invokeSingleNodeRequest(new PlayerNodeRequest(targetId) {
            @Override protected void execute (AetherClientObject target, ResultListener listener) {
                FriendshipRequest req = new FriendshipRequest(playerName, target.playerName);
                CommSender.receiveComm(target, req);
                listener.requestProcessed(req);
            }
        }, new Resulting<FriendshipRequest>(listener) {
            @Override public void requestCompleted (FriendshipRequest result) {
                super.requestCompleted(result);
                CommSender.receiveComm(caller, result);
            }
            @Override public void requestFailed (Exception cause) {
                throttle.clear(targetId);
                super.requestFailed(cause);
            }
        });
    }

    public void acceptFriendshipRequest (
        ClientObject caller, final int senderId, final InvocationListener listener)
        throws InvocationException
    {
        final AetherClientObject acceptingPlayer = (AetherClientObject)caller;
        final PlayerName acceptingPlayerName = acceptingPlayer.playerName;

        // forward this acceptance to the server the other player is on
        _peerMgr.invokeNodeRequest(new PlayerNodeRequest(senderId) {
            @Inject transient OrthPeerManager peermgr;
            @Inject transient FriendManager friendmgr;
            @Override protected void execute (AetherClientObject sender, ResultListener listener) {
                PlayerLocal local = sender.getLocal(PlayerLocal.class);
                if (!local.getInviteThrottle().clear(acceptingPlayerName.getId())) {
                    log.warning("Uninvited friend acceptance!", "player", acceptingPlayerName,
                        "sender", _targetPlayer);
                    listener.requestFailed(AetherCodes.INTERNAL_ERROR);
                    return;
                }

                // add the friend!
                OrthClientInfo other = peermgr.locatePlayer(acceptingPlayerName.getId());
                if (other == null) {
                    log.warning("Edge case, accepting friend logged off before sender received " +
                        "notification of friendship", "sender", sender,
                        "accepting", acceptingPlayerName);
                } else {
                    friendmgr.addNewFriend(sender, other);
                    CommSender.receiveComm(sender,
                        new FriendshipAcceptance(sender.playerName, acceptingPlayerName));
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
                       _friendRepo.addFriendship(acceptingPlayer.getPlayerId(), senderId);
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
    protected void initFriends (final AetherClientObject player)
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

    protected void updateFriends (AetherClientObject player, List<FriendEntry> friends)
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

    protected void shutdownFriends (AetherClientObject player)
    {
        log.debug("Removing friend notifications", "player", player);

        for (FriendEntry entry : player.friends) {
            _notifyMap.remove(entry.name.getId(), player);
        }
    }

    protected void notifyFriends (int playerId, FriendEntry.Status status)
    {
        log.debug("Notifying friends", "playerId", playerId, "status", status);

        for (AetherClientObject friend : _notifyMap.get(playerId)) {
            FriendEntry entry = friend.friends.get(playerId);
            if (entry == null) {
                continue;
            }
            entry = entry.clone();
            entry.status = status;
            friend.updateFriends(entry);
        }
    }

    protected void addNewFriend (AetherClientObject player, OrthClientInfo other)
    {
        if (other == null) {
            return;
        }
        player.addToFriends(toFriendEntry(other));
        _notifyMap.put(other.orthName.getId(), player);
    }

    protected static FriendEntry toFriendEntry (OrthClientInfo info)
    {
        return FriendEntry.fromOrthName(info.orthName, FriendEntry.Status.ONLINE);
    }

    /** Mapping of local and remote player ids to friend ids logged into this server. */
    protected SetMultimap<Integer, AetherClientObject> _notifyMap = HashMultimap.create();

    // dependencies
    @Inject protected AetherManager _aetherMgr;
    @Inject protected PlayerSessionLocator _locator;
    @Inject protected OrthPeerManager _peerMgr;
    @Inject protected PlayerRepository _playerRepo;
    @Inject protected RelationshipRepository _friendRepo;
    @Inject protected @MainInvoker Invoker _invoker;
}
