//
// $Id: WorldDirector.as 18771 2009-11-24 22:03:46Z jamie $

package com.threerings.orth.world.client {

import com.threerings.util.Log;

import com.threerings.presents.client.BasicDirector;
import com.threerings.presents.client.Client;

import com.threerings.orth.client.OrthContext;
import com.threerings.orth.data.OrthCodes;

import com.threerings.orth.room.data.OrthRoomConfig;
import com.threerings.orth.room.data.PetMarshaller;

/**
 * Handles moving around in the virtual world.
 *
 */
public class WorldDirector extends BasicDirector
{
    public const log :Log = Log.getLog(this);

    // statically reference classes we require
    PetMarshaller;
    OrthRoomConfig;

    public function WorldDirector (ctx :OrthContext)
    {
        super(ctx);

        _octx = ctx;

        _followingNotifier = new FollowingNotifier(_octx);
    }

    /**
     * Request a change to our avatar.
     */
    public function setAvatar (avatarId :int) :void
    {
        _wsvc.setAvatar(avatarId, _octx.confirmListener());
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
        client.addServiceGroup(OrthCodes.ROOM_GROUP);
    }

    // from BasicDirector
    override protected function fetchServices (client :Client) :void
    {
        super.fetchServices(client);

        // TODO: move more of the functions we use into a WorldService
        _wsvc = (client.requireService(WorldService) as WorldService);
    }

    protected var _octx :OrthContext;
    protected var _wsvc :WorldService;

    protected var _followingNotifier :FollowingNotifier;
}
}

import com.threerings.orth.aether.data.PlayerObject;
import com.threerings.orth.data.OrthName;
import com.threerings.util.MessageBundle;

import com.threerings.presents.dobj.AttributeChangeListener;
import com.threerings.presents.dobj.AttributeChangedEvent;
import com.threerings.presents.dobj.DSet;
import com.threerings.presents.dobj.EntryAddedEvent;
import com.threerings.presents.dobj.EntryRemovedEvent;
import com.threerings.presents.dobj.EntryUpdatedEvent;
import com.threerings.presents.dobj.SetListener;

import com.threerings.orth.client.OrthContext;
import com.threerings.orth.data.OrthCodes;

class FollowingNotifier
    implements AttributeChangeListener, SetListener
{
    public function FollowingNotifier (octx :OrthContext)
    {
        _octx = octx;
    }

    public function attributeChanged (event :AttributeChangedEvent) :void
    {
        switch (event.getName()) {
        case PlayerObject.FOLLOWING:
            var leader :OrthName = event.getValue() as OrthName;
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
                MessageBundle.tcompose("m.new_follower", event.getEntry() as OrthName));
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
                MessageBundle.tcompose("m.follower_ditched", event.getOldEntry() as OrthName));
        }
    }

    protected var _octx :OrthContext;
}