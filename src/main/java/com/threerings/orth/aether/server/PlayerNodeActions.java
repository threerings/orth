//
// $Id$

package com.threerings.orth.aether.server;

import java.util.List;

import com.google.common.base.Predicate;
import com.google.common.collect.Iterables;
import com.google.common.collect.Lists;
import com.google.inject.Inject;

import com.threerings.orth.aether.data.AetherAuthName;
import com.threerings.orth.aether.data.PlayerName;
import com.threerings.orth.aether.data.PlayerObject;
import com.threerings.orth.data.FriendEntry;
import com.threerings.orth.data.OrthCodes;
import com.threerings.orth.notify.data.Notification;
import com.threerings.orth.notify.server.NotificationManager;
import com.threerings.orth.peer.server.OrthPeerManager;
import com.threerings.presents.peer.data.NodeObject;
import com.threerings.presents.peer.server.PeerManager;

/**
 * Contains various player node actions.
 */
public class PlayerNodeActions
{
    /**
     * Send a mass-notification to all your friends.
     */
    public void notifyAllFriends (PlayerObject plobj, Notification notif)
    {
        if (plobj.friends.size() == 0) {
            return;
        }
        _peerMan.invokeNodeAction(new NotifyFriendsAction(plobj, notif));
    }

    /**
     * Boots a player from any server into which they are logged in.
     */
    public void bootPlayer (int playerId)
    {
        _peerMan.invokeNodeAction(new BootPlayer(playerId));
    }

    /**
     * Send a notification to a player
     */
    public void sendNotification (int playerId, Notification notification)
    {
        _peerMan.invokeNodeAction(new SendNotification(playerId, notification));
    }

    /**
     * Sends an invite to the specified player to the specified party.
     */
    public void inviteToParty (
        int playerId, PlayerName inviter, int partyId, String partyName)
    {
        _peerMan.invokeNodeAction(new PartyInviteAction(playerId, inviter, partyId, partyName));
    }

    /**
     * Sends an invite to all friends of the supplied inviter to the specified party.
     */
    public void inviteAllFriendsToParty (PlayerObject inviter, int partyId, String partyName)
    {
        if (inviter.friends.size() == 0) {
            return;
        }
        _peerMan.invokeNodeAction(new AllFriendsPartyInviteAction(inviter, partyId, partyName));
    }

    /**
     * Notifies a follower that the leader is on the move (and potentially decouples this follower
     * from the leader if that turns out to be the right thing to do).
     */
    public void followTheLeader (final int followerId, final int leaderId, int sceneId)
    {
        _peerMan.invokeNodeAction(new FollowTheLeaderAction(followerId, leaderId, sceneId),
                                  new Runnable() {
            public void run () {
                // didn't find the follower anywhere, remove them from the leader's follower set
                removeFollower(leaderId, followerId);
            }
        });
    }

    /**
     * Removes the specified follower from the specified leader's follower set.
     */
    public void removeFollower (int leaderId, int followerId)
    {
        _peerMan.invokeNodeAction(new RemoveFollowerAction(leaderId, followerId));
    }

    protected static class BootPlayer extends PlayerNodeAction
    {
        public BootPlayer (int playerId) {
            super(playerId);
        }

        public BootPlayer () {
        }

        @Override protected void execute (PlayerObject plobj) {
            _playerMan.bootPlayer(_playerId);
        }

        @Inject protected transient PlayerManager _playerMan;
    }

    protected static class SendNotification extends PlayerNodeAction
    {
        public SendNotification (int playerId, Notification notification) {
            super(playerId);
            _notification = notification;
        }

        public SendNotification () {
        }

        @Override protected void execute (PlayerObject plobj) {
            _notifyMan.notify(plobj, _notification);
        }

        protected Notification _notification;

        @Inject protected transient NotificationManager _notifyMan;
    }

    /**
     * An action for all *online* friends.
     */
    protected static abstract class AllFriendsAction extends PeerManager.NodeAction
    {
        public AllFriendsAction () {}

        public AllFriendsAction (PlayerObject plobj)
        {
            _friends = Lists.newArrayListWithCapacity(plobj.friends.size());
            for (FriendEntry entry : plobj.friends) {
                _friends.add(entry.name.getId());
            }
        }

        @Override public boolean isApplicable (final NodeObject nodeobj)
        {
            return Iterables.any(_friends, new Predicate<Integer>() {
                @Override public boolean apply (Integer friendId) {
                    return nodeobj.clients.containsKey(AetherAuthName.makeKey(friendId));
                }});
        }

        @Override protected void execute ()
        {
            for (int friendId : _friends) {
                PlayerObject plobj = _locator.lookupPlayer(friendId);
                if (plobj != null) {
                    execute(plobj);
                }
            }
        }

        protected abstract void execute (PlayerObject plobj);

        protected List<Integer> _friends;

        /** Used to look up player objects. */
        @Inject protected transient PlayerLocator _locator;
    }

    protected static class FriendEntryUpdate extends AllFriendsAction
    {
        public FriendEntryUpdate () {}

        public FriendEntryUpdate (PlayerObject plobj)
        {
            super(plobj);

            _entry = new FriendEntry(plobj.playerName, "");
        }

        @Override protected void execute (PlayerObject plobj)
        {
            if (plobj.friends.containsKey(_entry.getKey())) {
                plobj.updateFriends(_entry);
            } else {
                plobj.addToFriends(_entry);
            }
        }

        protected FriendEntry _entry;
    }

    protected static class NotifyFriendsAction extends AllFriendsAction
    {
        public NotifyFriendsAction () {}

        public NotifyFriendsAction (PlayerObject plobj, Notification notification)
        {
            super(plobj);
            _notification = notification;
        }

        @Override protected void execute (PlayerObject plobj)
        {
            _notifyMan.notify(plobj, _notification);
        }

        protected Notification _notification;

        @Inject protected transient NotificationManager _notifyMan;
    }

    // ORTH TODO
    protected static class PartyInviteAction extends PlayerNodeAction
    {
        public PartyInviteAction () {}

        public PartyInviteAction (
            int targetId, PlayerName inviter, int partyId, String partyName)
        {
            super(targetId);
            _inviter = inviter;
            _partyId = partyId;
            _partyName = partyName;
        }

        @Override protected void execute (PlayerObject plobj) {
//            _partyReg.issueInvite(plobj, _inviter, _partyId, _partyName);
        }

        protected PlayerName _inviter;
        protected int _partyId;
        protected String _partyName;
//        @Inject protected transient PartyRegistry _partyReg;
    }

    // ORTH TODO
    protected static class AllFriendsPartyInviteAction extends AllFriendsAction
    {
        public AllFriendsPartyInviteAction () {}

        public AllFriendsPartyInviteAction (PlayerObject inviter, int partyId, String partyName)
        {
            super(inviter);
            _inviter = inviter.playerName.toPlayerName();
            _partyId = partyId;
            _partyName = partyName;
        }

        @Override protected void execute (PlayerObject plobj) {
//            _partyReg.issueInvite(plobj, _inviter, _partyId, _partyName);
        }

        protected PlayerName _inviter;
        protected int _partyId;
        protected String _partyName;
//        @Inject protected transient PartyRegistry _partyReg;
    }

    protected static class FollowTheLeaderAction extends PlayerNodeAction
    {
        public FollowTheLeaderAction (int playerId, int leaderId, int sceneId) {
            super(playerId);
            _sceneId = sceneId;
            _leaderId = leaderId;
        }

        public FollowTheLeaderAction () {
        }

        @Override protected void execute (PlayerObject plobj) {
            if (plobj.following == null || plobj.following.getId() != _leaderId) {
                // oops, no longer following this leader
                _peerMan.invokeNodeAction(
                    new RemoveFollowerAction(_leaderId, plobj.getPlayerId()));
            } else {
                plobj.postMessage(OrthCodes.FOLLOWEE_MOVED, _sceneId);
            }
        }

        protected int _leaderId;
        protected int _sceneId;

        @Inject protected transient OrthPeerManager _peerMan;
    }

    protected static class RemoveFollowerAction extends PlayerNodeAction
    {
        public RemoveFollowerAction (int leaderId, int followerId) {
            super(leaderId);
            _followerId = followerId;
        }

        public RemoveFollowerAction () {
        }

        @Override protected void execute (PlayerObject plobj) {
            if (plobj.followers.containsKey(_followerId)) {
                plobj.removeFromFollowers(_followerId);
            }
        }

        protected int _followerId;
    }

    @Inject protected OrthPeerManager _peerMan;
}
