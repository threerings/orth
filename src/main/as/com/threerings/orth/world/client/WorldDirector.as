//
// $Id: WorldDirector.as 18771 2009-11-24 22:03:46Z jamie $

package com.threerings.orth.world.client {

import com.threerings.io.TypedArray;
import com.threerings.orth.data.OrthCodes;
import com.threerings.orth.data.PlayerObject;
import com.threerings.orth.world.client.WorldContext;
import com.threerings.util.Util;
import com.threerings.util.Log;

import com.threerings.presents.client.BasicDirector;
import com.threerings.presents.client.Client;
import com.threerings.presents.client.ClientAdapter;

import com.threerings.crowd.client.LocationAdapter;
import com.threerings.crowd.data.PlaceObject;

/**
 * Handles moving around in the virtual world.
 */
public class WorldDirector extends BasicDirector
{
    public const log :Log = Log.getLog(this);

    // statically reference classes we require
    PetMarshaller;
    RoomConfig;

    public function WorldDirector (ctx :WorldContext)
    {
        super(ctx);
        _wctx = ctx;
        _wctx.getLocationDirector().addLocationObserver(
            new LocationAdapter(null, locationDidChange, null));

        _followingNotifier = new FollowingNotifier(_wctx);
    }

    /**
     * Request a change to our avatar.
     *
     * @param newScale a new scale to use, or 0 to retain the avatar's last scale.
     */
    public function setAvatar (avatarId :int) :void
    {
        _wsvc.setAvatar(avatarId, _wctx.confirmListener());
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
        client.addServiceGroup(MsoyCodes.WORLD_GROUP);
    }

    // from BasicDirector
    override protected function fetchServices (client :Client) :void
    {
        super.fetchServices(client);

        // TODO: move more of the functions we use into a WorldService
        _wsvc = (client.requireService(WorldService) as WorldService);
    }

    protected var _wctx :WorldContext;
    protected var _wsvc :WorldService;

    protected var _followingNotifier :FollowingNotifier;
}
}

import com.threerings.util.MessageBundle;

import com.threerings.presents.dobj.AttributeChangeListener;
import com.threerings.presents.dobj.AttributeChangedEvent;
import com.threerings.presents.dobj.DSet;
import com.threerings.presents.dobj.EntryAddedEvent;
import com.threerings.presents.dobj.EntryRemovedEvent;
import com.threerings.presents.dobj.EntryUpdatedEvent;
import com.threerings.presents.dobj.SetListener;

class FollowingNotifier
    implements AttributeChangeListener, SetListener
{
    public function FollowingNotifier (wctx :WorldContext)
    {
        _wctx = wctx;
    }

    public function attributeChanged (event :AttributeChangedEvent) :void
    {
        switch (event.getName()) {
        case PlayerObject.FOLLOWING:
            var leader :OrthName = event.getValue() as OrthName;
            if (leader != null) {
                _wctx.displayFeedback(OrthCodes.GENERAL_MSGS,
                    MessageBundle.tcompose("m.following", leader));
            } else if (event.getOldValue() != null) {
                _wctx.displayFeedback(OrthCodes.GENERAL_MSGS,
                    MessageBundle.tcompose("m.not_following", event.getOldValue()));
            }
            break;

        case PlayerObject.FOLLOWERS:
            var followers :DSet = event.getValue() as DSet;
            if (followers.size() == 0) {
                _wctx.displayFeedback(OrthCodes.GENERAL_MSGS, "m.follows_cleared");
            }
            break;
        }
    }

    public function entryAdded (event :EntryAddedEvent) :void
    {
        if (PlayerObject.FOLLOWERS == event.getName()) {
            _wctx.displayFeedback(OrthCodes.GENERAL_MSGS,
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
            _wctx.displayFeedback(OrthCodes.GENERAL_MSGS,
                MessageBundle.tcompose("m.follower_ditched", event.getOldEntry() as OrthName));
        }
    }

    protected var _wctx :WorldContext;
}
