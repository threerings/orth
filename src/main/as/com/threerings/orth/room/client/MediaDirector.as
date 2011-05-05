//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.
package com.threerings.orth.room.client {
import flashx.funk.ioc.Module;
import flashx.funk.ioc.inject;

import com.threerings.crowd.client.LocationAdapter;
import com.threerings.crowd.client.LocationDirector;
import com.threerings.crowd.data.OccupantInfo;
import com.threerings.crowd.data.PlaceObject;

import com.threerings.util.Log;

import com.threerings.presents.client.BasicDirector;
import com.threerings.presents.client.ClientEvent;

import com.threerings.orth.entity.client.EntitySprite;
import com.threerings.orth.entity.client.FurniSprite;
import com.threerings.orth.entity.client.MemberSprite;
import com.threerings.orth.entity.client.OccupantSprite;
import com.threerings.orth.entity.client.ParallaxSprite;
import com.threerings.orth.entity.client.PetSprite;
import com.threerings.orth.room.data.FurniData;
import com.threerings.orth.room.data.OrthRoomObject;
import com.threerings.orth.room.data.PetInfo;
import com.threerings.orth.room.data.SocializerInfo;

/**
 * Handles the loading of various media.
 */
public class MediaDirector extends BasicDirector
{
    public static const log :Log = Log.getLog(MediaDirector);

    public function MediaDirector (ctx :RoomContext, locDir :LocationDirector)
    {
        super(ctx);

        _wctx = ctx;

        locDir.addLocationObserver(new LocationAdapter(null, locationDidChange));
    }

    /**
     * Creates an occupant sprite for the specified occupant info.
     *
     * @param extraInfo not yet defined, but an object from which to cull additional info
     */
    public function getSprite (occInfo :OccupantInfo, extraInfo :Object) :OccupantSprite
    {
        if (occInfo is SocializerInfo) {
            var isOurs :Boolean = _wctx.getMyName().equals(occInfo.username);
            if (isOurs && _ourAvatar != null) {
                _ourAvatar.setOccupantInfo(occInfo, extraInfo);
                return _ourAvatar;
            }
            var mSprite :MemberSprite = _module.getInstance(MemberSprite);
            mSprite.initMemberSprite(occInfo as SocializerInfo, extraInfo);
            if (isOurs) {
                _ourAvatar = mSprite;
            }
            return mSprite;

        } else if (occInfo is PetInfo) {
            var pSprite :PetSprite = _module.getInstance(PetSprite);
            pSprite.initPetSprite(occInfo as PetInfo, extraInfo);
            return pSprite;

        } else {
            log.warning("Don't know how to create sprite for occupant " + occInfo + ".");
            return null;
        }
    }

    /**
     * Get a Furni sprite for the specified furni data, caching as appropriate.
     */
    public function getFurni (furni :FurniData) :FurniSprite
    {
        var sprite :FurniSprite = _module.getInstance(
            furni.isParallax() ? ParallaxSprite : FurniSprite);
        sprite.initFurniSprite(furni);
        return sprite;
    }

    /**
     * Release any references to the specified sprite, if appropriate.
     */
    public function returnSprite (sprite :EntitySprite) :void
    {
        if (sprite != _ourAvatar) {
            sprite.shutdown();

        } else {
            // prevent it from continuing to move, but don't shut it down
            _ourAvatar.stopMove();
        }
    }

    override public function clientDidLogoff (event :ClientEvent) :void
    {
        super.clientDidLogoff(event);

        shutdownOurAvatar();
    }

    /**
     * This method is adapted as a LocationObserver method.
     */
    protected function locationDidChange (place :PlaceObject) :void
    {
        // if we've moved to a non-room, kill our avatar
        if (!(place is OrthRoomObject)) {
            shutdownOurAvatar();
        }
    }

    protected function shutdownOurAvatar () :void
    {
        // release our hold on our avatar
        if (_ourAvatar != null) {
            _ourAvatar.shutdown();
            _ourAvatar = null;
        }
    }

    // the wellspring of new classes
    protected const _module :Module = inject(Module);

    /** A casted copy of the context. */
    protected var _wctx :RoomContext;

    /** Our very own avatar: avoid loading and unloading it. */
    protected var _ourAvatar :MemberSprite;
}
}
