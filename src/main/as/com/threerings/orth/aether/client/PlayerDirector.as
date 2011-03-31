//
// $Id: $

package com.threerings.orth.aether.client {
import flashx.funk.ioc.inject;

import com.threerings.util.Log;

import com.threerings.presents.client.BasicDirector;
import com.threerings.presents.client.Client;
import com.threerings.presents.client.ClientEvent;
import com.threerings.presents.dobj.MessageAdapter;
import com.threerings.presents.dobj.MessageEvent;

import com.threerings.orth.client.OrthContext;
import com.threerings.orth.data.OrthCodes;
import com.threerings.orth.locus.client.LocusDirector;
import com.threerings.orth.room.data.RoomLocus;

/**
 * Handles player-oriented requests.
 */
public class PlayerDirector extends BasicDirector
{
    public const log :Log = Log.getLog(this);

    public function PlayerDirector ()
    {
        super(_octx);

        _followingNotifier = new FollowingNotifier();
    }

    /**
     * Request a change to our avatar.
     */
    public function setAvatar (avatarId :int) :void
    {
        _psvc.setAvatar(avatarId, _octx.confirmListener());
    }

    public function inviteFriend (playerId :int) :void
    {
        _psvc.requestFriendship(playerId, _octx.listener());
    }

    public function acceptFriendInvite (friendId :int) :void
    {
        _psvc.acceptFriendshipRequest(friendId, _octx.listener());
    }

    // documentation inherited
    override public function clientDidLogon (event :ClientEvent) :void
    {
        super.clientDidLogon(event);

        // add a listener that will respond to follow notifications
        _ctx.getClient().getClientObject().addListener(_followListener);
    }

    // from BasicDirector
    override protected function clientObjectUpdated (client :Client) :void
    {
        super.clientObjectUpdated(client);
        client.getClientObject().addListener(_followingNotifier);
    }

    // from BasicDirector
    override protected function registerServices (client :Client) :void
    {
        client.addServiceGroup(OrthCodes.AETHER_GROUP);
    }

    // from BasicDirector
    override protected function fetchServices (client :Client) :void
    {
        super.fetchServices(client);

        // TODO: move more of the functions we use into a LocusService
        _psvc = (client.requireService(PlayerService) as PlayerService);
    }

    protected function memberMessageReceived (event :MessageEvent) :void
    {
        if (event.getName() == OrthCodes.FOLLOWEE_MOVED) {
            var sceneId :int = int(event.getArgs()[0]);
            log.info("Following " + _octx.getPlayerObject().following + " to " + sceneId + ".");
            // ORTH TODO: make this non-room-specific
            _locusDir.moveTo(new RoomLocus(sceneId));
        }
    }

    protected const _locusDir :LocusDirector = inject(LocusDirector);
    protected const _octx :OrthContext = inject(OrthContext);

    protected var _psvc :PlayerService;

    protected var _followingNotifier :FollowingNotifier;
    protected var _followListener :MessageAdapter = new MessageAdapter(memberMessageReceived);
}
}

import flashx.funk.ioc.inject;

import com.threerings.util.MessageBundle;

import com.threerings.presents.dobj.AttributeChangeListener;
import com.threerings.presents.dobj.AttributeChangedEvent;
import com.threerings.presents.dobj.DSet;
import com.threerings.presents.dobj.EntryAddedEvent;
import com.threerings.presents.dobj.EntryRemovedEvent;
import com.threerings.presents.dobj.EntryUpdatedEvent;
import com.threerings.presents.dobj.SetListener;

import com.threerings.orth.aether.data.PlayerName;
import com.threerings.orth.aether.data.PlayerObject;
import com.threerings.orth.client.OrthContext;
import com.threerings.orth.data.OrthCodes;

class FollowingNotifier
    implements AttributeChangeListener, SetListener
{
    public function attributeChanged (event :AttributeChangedEvent) :void
    {
        switch (event.getName()) {
        case PlayerObject.FOLLOWING:
            var leader :PlayerName = event.getValue() as PlayerName;
            if (leader != null) {
                _octx.displayFeedback(OrthCodes.GENERAL_MSGS,
                    MessageBundle.tcompose("m.following", leader));
            } else if (event.getOldValue() != null) {
                _octx.displayFeedback(OrthCodes.GENERAL_MSGS,
                    MessageBundle.tcompose("m.not_following", event.getOldValue()));
            }
            break;

        case PlayerObject.FOLLOWERS:
            var followers :DSet = event.getValue() as DSet;
            if (followers.size() == 0) {
                _octx.displayFeedback(OrthCodes.GENERAL_MSGS, "m.follows_cleared");
            }
            break;
        }
    }

    public function entryAdded (event :EntryAddedEvent) :void
    {
        if (PlayerObject.FOLLOWERS == event.getName()) {
            _octx.displayFeedback(OrthCodes.GENERAL_MSGS,
                MessageBundle.tcompose("m.new_follower", event.getEntry() as PlayerName));
        }
    }

    public function entryUpdated (event :EntryUpdatedEvent) :void
    {
        // everybody noops
    }

    public function entryRemoved (event :EntryRemovedEvent) :void
    {
        if (PlayerObject.FOLLOWERS == event.getName()) {
            _octx.displayFeedback(OrthCodes.GENERAL_MSGS,
                MessageBundle.tcompose("m.follower_ditched", event.getOldEntry() as PlayerName));
        }
    }

    protected const _octx :OrthContext = inject(OrthContext);
}
