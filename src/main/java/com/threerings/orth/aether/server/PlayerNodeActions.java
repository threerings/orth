//
// $Id: $

package com.threerings.orth.aether.server;

import com.google.inject.Inject;

import com.threerings.presents.peer.data.NodeObject;
import com.threerings.presents.peer.server.PeerManager;
import com.threerings.orth.world.data.WorldCodes;

import com.threerings.orth.aether.data.PlayerName;
import com.threerings.orth.aether.data.PlayerObject;
import com.threerings.orth.aether.server.PlayerLocator;
import com.threerings.orth.aether.server.PlayerManager;
import com.threerings.orth.aether.server.PlayerNodeAction;

import com.threerings.orth.data.AuthName;
import com.threerings.orth.data.FriendEntry;

import com.threerings.orth.notify.data.Notification;
import com.threerings.orth.notify.server.NotificationManager;

// import com.threerings.orth.party.server.PartyRegistry;

import com.threerings.orth.peer.data.OrthNodeObject;
import com.threerings.orth.peer.server.OrthPeerManager;

/**
 * Contains various player node actions.
 */
public class PlayerNodeActions
{
    /**
     * Provides us with our peer manager reference. TODO: nix this and require callers to inject a
     * PlayerNodeActions instance.
     */
    public static void init (OrthPeerManager peerMan)
    {
        _peerMan = peerMan;
    }

    /**
     * Send a mass-notification to all your friends.
     */
    public static void notifyAllFriends (PlayerObject plobj, Notification notif)
    {
        if (plobj.friends.size() == 0) {
            return;
        }
        _peerMan.invokeNodeAction(new NotifyFriendsAction(plobj, notif));
    }

    /**
     * Boots a player from any server into which they are logged in.
     */
    public static void bootPlayer (int playerId)
    {
        _peerMan.invokeNodeAction(new BootPlayer(playerId));
    }

    /**
     * Send a notification to a player
     */
    public static void sendNotification (int playerId, Notification notification)
    {
        _peerMan.invokeNodeAction(new SendNotification(playerId, notification));
    }

    /**
     * Sends an invite to the specified player to the specified party.
     */
    public static void inviteToParty (
        int playerId, PlayerName inviter, int partyId, String partyName)
    {
        _peerMan.invokeNodeAction(new PartyInviteAction(playerId, inviter, partyId, partyName));
    }

    /**
     * Sends an invite to all friends of the supplied inviter to the specified party.
     */
    public static void inviteAllFriendsToParty (PlayerObject inviter, int partyId, String partyName)
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
    public static void followTheLeader (final int followerId, final int leaderId, int sceneId)
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
    public static void removeFollower (int leaderId, int followerId)
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
            _friends = new int[plobj.friends.size()];
            int ii = 0;
            for (FriendEntry entry : plobj.friends) {
                _friends[ii++] = entry.name.getId();
            }
        }

        @Override public boolean isApplicable (NodeObject nodeobj)
        {
            OrthNodeObject orthNode = (OrthNodeObject)nodeobj;
            for (int friendId : _friends) {
                if (orthNode.clients.containsKey(AuthName.makeKey(friendId))) {
                    return true;
                }
            }
            // no friends found here, move along
            return false;
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

        protected int[] _friends;

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
                plobj.postMessage(WorldCodes.FOLLOWEE_MOVED, _sceneId);
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

    protected static OrthPeerManager _peerMan;
}
