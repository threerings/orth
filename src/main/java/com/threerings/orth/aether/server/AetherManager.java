//
// $Id$

package com.threerings.orth.aether.server;

import static com.threerings.orth.Log.log;

import com.google.inject.Inject;
import com.google.inject.Injector;
import com.google.inject.Singleton;

import com.samskivert.util.Lifecycle;
import com.samskivert.util.ObserverList;

import com.threerings.presents.annotation.EventThread;
import com.threerings.presents.client.InvocationService;
import com.threerings.presents.client.InvocationService.InvocationListener;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.dobj.DSet;
import com.threerings.presents.server.InvocationException;
import com.threerings.presents.server.InvocationManager;
import com.threerings.util.Resulting;

import com.threerings.orth.aether.data.AetherAuthName;
import com.threerings.orth.aether.data.AetherCodes;
import com.threerings.orth.aether.data.PlayerMarshaller;
import com.threerings.orth.aether.data.PlayerName;
import com.threerings.orth.aether.data.PlayerObject;
import com.threerings.orth.data.OrthCodes;
import com.threerings.orth.guild.data.GuildCodes;
import com.threerings.orth.guild.server.GuildRegistry;
import com.threerings.orth.nodelet.data.HostedNodelet;
import com.threerings.orth.notify.server.NotificationManager;
import com.threerings.orth.peer.server.OrthPeerManager;

/**
 * Manage Orth Players.
 */
@Singleton @EventThread
public class AetherManager
    implements PlayerProvider, Lifecycle.InitComponent, AetherCodes
{
    @Inject public AetherManager (Injector injector)
    {
        // register our bootstrap invocation service
        injector.getInstance(InvocationManager.class).registerProvider(
            this, PlayerMarshaller.class, OrthCodes.AETHER_GROUP);

        // observe aether auths from afar
        _observers = injector.getInstance(OrthPeerManager.class).observe(AetherAuthName.class);

        // get our init call
        injector.getInstance(Lifecycle.class).addComponent(this);
    }

    /**
     * Prepares our manager for operation.
     */
    @Override public void init ()
    {
        // nothing yet
    }

    public void addObserver (OrthPeerManager.FarSeeingObserver<PlayerName> observer)
    {
        _observers.add(observer);
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
        _friendMgr.requestFriendship(caller, targetId, listener);
    }

    @Override
    public void acceptFriendshipRequest (
        ClientObject caller, final int senderId, final InvocationListener listener)
        throws InvocationException
    {
        _friendMgr.acceptFriendshipRequest(caller, senderId, listener);
    }

    @Override
    public void createGuild (ClientObject caller, String name, InvocationListener lner)
        throws InvocationException
    {
        // TODO: permissions and money
        PlayerObject player = (PlayerObject)caller;
        if (player.guild != null) {
            throw new InvocationException(GuildCodes.E_PLAYER_ALREADY_IN_GUILD);
        }
        if (name.length() == 0) {
            throw new InvocationException(E_INTERNAL_ERROR);
        }

        _guildReg.createAndHostGuild(name, player, new Resulting<HostedNodelet>(lner));
    }

    /** Observers of aether logins throughout the cluster. */
    protected ObserverList<OrthPeerManager.FarSeeingObserver<PlayerName>> _observers;

    @Inject protected NotificationManager _notifyMan;
    @Inject protected PlayerNodeActions _actions;
    @Inject protected PlayerSessionLocator _locator;
    @Inject protected OrthPeerManager _peermgr;
    @Inject protected FriendManager _friendMgr;
    @Inject protected GuildRegistry _guildReg;
}
