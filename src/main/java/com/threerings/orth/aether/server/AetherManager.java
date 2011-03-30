//
// $Id: $

package com.threerings.orth.aether.server;

import static com.threerings.orth.Log.log;

import java.util.Map;

import com.google.inject.Inject;
import com.google.inject.Singleton;

import com.threerings.orth.aether.data.AetherCodes;
import com.threerings.orth.aether.data.PlayerMarshaller;
import com.threerings.orth.aether.data.PlayerName;
import com.threerings.orth.aether.data.PlayerObject;
import com.threerings.orth.aether.server.persist.RelationshipRepository;
import com.threerings.orth.data.OrthCodes;
import com.threerings.orth.notify.data.FriendInviteNotification;
import com.threerings.orth.notify.server.NotificationManager;
import com.threerings.orth.peer.server.OrthPeerManager;
import com.threerings.presents.annotation.EventThread;
import com.threerings.presents.client.InvocationService;
import com.threerings.presents.client.InvocationService.InvocationListener;
import com.threerings.presents.client.InvocationService.ResultListener;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.dobj.DSet;
import com.threerings.presents.peer.server.NodeRequestsListener;
import com.threerings.presents.server.InvocationException;
import com.threerings.presents.server.InvocationManager;

/**
 * Manage Orth Players.
 */
@Singleton @EventThread
public class AetherManager
    implements PlayerProvider
{
    public static class FriendshipRequest extends PlayerNodeRequest
    {
        public FriendshipRequest (PlayerName sender, int targetPlayerId)
        {
            super(targetPlayerId);
            _sender = sender;
        }

        @Override
        protected void execute (PlayerObject player, ResultListener listener)
        {
            _notMgr.notify(player, new FriendInviteNotification(_sender));
            listener.requestProcessed(null);
        }

        protected PlayerName _sender;
        @Inject transient NotificationManager _notMgr;
    }

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
        // nothing yet
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
        final Map<Integer, Long> pending = player.getLocal(PlayerLocal.class).pendingFriendRequests;
        Long lastRequest = pending.get(targetId);
        long now = System.currentTimeMillis();
        if (lastRequest != null && now - lastRequest < MIN_FRIEND_REQUEST_PERIOD) {
            throw new InvocationException(AetherCodes.FRIEND_REQUEST_ALREADY_SENT);
        }
        pending.put(targetId, now);
        _peermgr.invokeNodeRequest(new FriendshipRequest(player.getPlayerName(), targetId),
                new NodeRequestsListener<Void>() {
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
        ClientObject caller, int senderId, InvocationListener listener)
        throws InvocationException
    {
        // TODO: post a peer request for the senderId and persist it
        listener.requestFailed(AetherCodes.E_INTERNAL_ERROR);
    }

    protected static final long MIN_FRIEND_REQUEST_PERIOD = 60 * 1000L;

    // ORTH TODO: Implement NotificationManager
    // @Inject protected NotificationManager _notifyMan;
    @Inject protected PlayerNodeActions _actions;
    @Inject protected PlayerLocator _locator;
    @Inject protected OrthPeerManager _peermgr;
    @Inject protected RelationshipRepository _friendrepo;
}
