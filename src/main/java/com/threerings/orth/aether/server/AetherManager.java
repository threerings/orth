//
// $Id$

package com.threerings.orth.aether.server;

import static com.threerings.orth.Log.log;

import java.util.Iterator;
import java.util.List;
import java.util.Map;

import com.google.common.base.Objects;
import com.google.common.collect.Lists;
import com.google.inject.Inject;
import com.google.inject.Singleton;

import com.samskivert.util.Invoker;
import com.samskivert.util.ObserverList;

import com.threerings.orth.aether.data.AetherAuthName;
import com.threerings.orth.aether.data.AetherCodes;
import com.threerings.orth.aether.data.PlayerMarshaller;
import com.threerings.orth.aether.data.PlayerName;
import com.threerings.orth.aether.data.PlayerObject;
import com.threerings.orth.aether.server.persist.RelationshipRepository;
import com.threerings.orth.data.FriendEntry;
import com.threerings.orth.data.OrthCodes;
import com.threerings.orth.notify.data.FriendInviteNotification;
import com.threerings.orth.notify.server.NotificationManager;
import com.threerings.orth.peer.data.OrthClientInfo;
import com.threerings.orth.peer.server.OrthPeerManager;
import com.threerings.orth.server.persist.OrthPlayerRepository;
import com.threerings.presents.annotation.EventThread;
import com.threerings.presents.annotation.MainInvoker;
import com.threerings.presents.client.InvocationService;
import com.threerings.presents.client.InvocationService.InvocationListener;
import com.threerings.presents.client.InvocationService.ResultListener;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.dobj.DSet;
import com.threerings.presents.peer.server.NodeRequestsListener;
import com.threerings.presents.server.InvocationException;
import com.threerings.presents.server.InvocationManager;
import com.threerings.util.Resulting;

/**
 * Manage Orth Players.
 */
@Singleton @EventThread
public class AetherManager
    implements PlayerProvider
{
    @Inject public AetherManager (InvocationManager invmgr)
    {
        // register our bootstrap invocation service
        invmgr.registerProvider(this, PlayerMarshaller.class, OrthCodes.AETHER_GROUP);
    }

    /**
     * Prepares our manager for operation.
     */
    public void init ()
    {
        _observers = _peermgr.observe(AetherAuthName.class);

        _observers.add(new OrthPeerManager.FarSeeingObserver<PlayerName>() {
            @Override public void loggedOn (String node, PlayerName member) {
                boolean local = Objects.equal(_peermgr.getNodeObject().nodeName, node);
                if (local) {
                    initFriends(member.getId());
                }
                notifyFriends(member.getId(), true);
            }
            @Override public void loggedOff (String node, PlayerName member) {
                boolean local = Objects.equal(_peermgr.getNodeObject().nodeName, node);
                if (local) {
                    shutdownFriends(member.getId());
                }
                notifyFriends(member.getId(), false);
            }
        });
    }

    @Override
    public void dispatchDeferredNotifications (ClientObject caller)
    {
        _notifyMan.dispatchDeferredNotifications(caller);
    }

    @Override // from interface WorldProvider
    public void inviteToFollow (final ClientObject caller, final int playerId,
                                final InvocationService.InvocationListener listener)
        throws InvocationException
    {
        //final PlayerObject user = (PlayerObject) caller; //

        // make sure the target player is online and in the same room as the requester
        //final PlayerObject target = _locator.lookupPlayer(playerId);
        //if (target == null || !ObjectUtil.equals(user.location, target.location)) {
        //    throw new InvocationException("e.follow_not_in_room");
        //}

        // ORTH TODO: Implement _notifyMan
        // issue the follow invitation to the target
        // _notifyMan.notifyFollowInvite(target, user.playerName);
    }

    @Override // from interface WorldProvider
    public void followPlayer (final ClientObject caller, final int playerId,
                              final InvocationService.InvocationListener listener)
        throws InvocationException
    {
        final PlayerObject user = (PlayerObject) caller;

        // if the caller is requesting to clear their follow, do so
        if (playerId == 0) {
            if (user.following != null) {
                _actions.removeFollower(user.following.getId(), user.getPlayerId());
                user.setFollowing(null);
            }
            return;
        }

        // Make sure the target isn't bogus
        final PlayerObject target = _locator.lookupPlayer(playerId);
        if (target == null) {
            throw new InvocationException("e.follow_invite_expired");
        }

        // Wire up both the leader and follower
        if (!target.followers.containsKey(user.getPlayerId())) {
            log.debug("Adding follower", "follower", user.who(), "target", target.who());
            target.addToFollowers(user.playerName);
        }
        user.setFollowing(target.playerName);
    }

    @Override // from interface WorldProvider
    public void ditchFollower (ClientObject caller, int followerId,
                               InvocationService.InvocationListener listener)
        throws InvocationException
    {
        final PlayerObject leader = (PlayerObject) caller;

        if (followerId == 0) { // Clear all followers
            for (PlayerName follower : leader.followers) {
                PlayerObject fmo = _locator.lookupPlayer(follower.getId());
                if (fmo != null) {
                    fmo.setFollowing(null);
                }
            }
            leader.setFollowers(new DSet<PlayerName>());

        } else { // Ditch a single follower
            if (leader.followers.containsKey(followerId)) {
                leader.removeFromFollowers(followerId);
            }
            PlayerObject follower = _locator.lookupPlayer(followerId);
            if (follower != null && follower.following != null &&
                follower.following.getId() == leader.getPlayerId()) {
                follower.setFollowing(null);
            }
        }
    }

    @Override // from interface WorldProvider
    public void setAvatar (ClientObject caller, int avatarItemId,
        final InvocationService.ConfirmListener listener)
        throws InvocationException
    {
        // ORTH TODO: To Be Implemented
        // final PlayerObject user = (PlayerObject) caller;
    }

    @Override
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

    @Override
    public void acceptFriendshipRequest (
        ClientObject caller, final int senderId, final InvocationListener listener)
        throws InvocationException
    {
        final PlayerObject acceptingPlayer = (PlayerObject)caller;
        final int acceptingPlayerId = acceptingPlayer.getPlayerId();

        // forward this acceptance to the server the other player is on
        _peermgr.invokeNodeRequest(new PlayerNodeRequest(senderId) {
            @Inject transient OrthPeerManager peermgr;
            @Override protected void execute (PlayerObject sender, ResultListener listener) {
                PlayerLocal local = sender.getLocal(PlayerLocal.class);
                if (local.pendingFriendRequests.remove(acceptingPlayerId) == null) {
                    log.warning("Uninvited friend acceptance!", "playerId", acceptingPlayerId,
                        "sender", _targetPlayer);
                    listener.requestFailed(AetherCodes.INTERNAL_ERROR);
                    return;
                }

                // add the friend!
                addFriend(sender, peermgr.locatePlayer(acceptingPlayerId));

                // finished, go back to the original peer
                listener.requestProcessed(null);
            }
        }, new NodeRequestsListener<Void>() {
            @Override public void requestsProcessed (NodeRequestsResult<Void> result) {
                // all clear, add the friend!
                addFriend(acceptingPlayer, _peermgr.locatePlayer(senderId));

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
    protected void initFriends (final int memberId)
    {
        final PlayerObject player = _locator.lookupPlayer(memberId);
        if (player == null) {
            log.warning("Expected the player to be resolved by now", "memberId", memberId);
            return;
        }
        if (player.friends.size() != 0) {
            log.warning("Friends already? Something is very wrong.", "player", player.who());
            return;
        }

        final PlayerLocal local = player.getLocal(PlayerLocal.class);
        final List<FriendEntry> friends = Lists.newArrayListWithCapacity(
            local.unresolvedFriendIds.size());
        for (Iterator<Integer> iter = local.unresolvedFriendIds.iterator(); iter.hasNext(); ) {
            Integer friendId = iter.next();
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

    protected void initFriends2 (PlayerObject player, List<FriendEntry> friends)
    {
        // the player may have had some friends come online already, replace the ones in our list
        // this is inefficient but very very rare
        for (FriendEntry entry : player.friends) {
            friends.remove(entry);
        }

        // set the friends
        player.setFriends(DSet.newDSet(friends));

        // clear out the holding buffer
        player.getLocal(PlayerLocal.class).unresolvedFriendIds = null;
    }

    protected void shutdownFriends (int memberId)
    {
        // TODO
    }

    protected void notifyFriends (int memberId, boolean online)
    {
        // TODO
    }

    protected static FriendEntry toFriendEntry (OrthClientInfo info)
    {
        return FriendEntry.fromPlayerName(info.playerName, FriendEntry.Status.ONLINE);
    }

    protected static void addFriend (PlayerObject player, OrthClientInfo other)
    {
        if (other == null) {
            return;
        }
        player.addToFriends(toFriendEntry(other));
    }

    protected static final long MIN_FRIEND_REQUEST_PERIOD = 60 * 1000L;

    /** Observers of aether logins throughout the cluster. */
    protected ObserverList<OrthPeerManager.FarSeeingObserver<PlayerName>> _observers;

    // ORTH TODO: Implement NotificationManager
    @Inject protected NotificationManager _notifyMan;
    @Inject protected PlayerNodeActions _actions;
    @Inject protected PlayerLocator _locator;
    @Inject protected OrthPeerManager _peermgr;
    @Inject protected OrthPlayerRepository _playerrepo;
    @Inject protected RelationshipRepository _friendrepo;
    @Inject protected @MainInvoker Invoker _invoker;
}
