//
// $Id: MediaDirector.as 19622 2010-11-23 22:59:49Z zell $

package com.threerings.orth.room.client {
import com.threerings.orth.entity.client.MemberSprite;
import com.threerings.orth.entity.client.PetSprite;
import com.threerings.util.Log;

import com.threerings.presents.client.BasicDirector;
import com.threerings.presents.client.ClientEvent;

import com.threerings.crowd.client.LocationAdapter;
import com.threerings.crowd.data.OccupantInfo;
import com.threerings.crowd.data.PlaceObject;

import com.threerings.orth.entity.client.Decor;
import com.threerings.orth.entity.client.DecorSprite;
import com.threerings.orth.entity.client.EntitySprite;
import com.threerings.orth.entity.client.FurniSprite;
import com.threerings.orth.entity.client.OccupantSprite;
import com.threerings.orth.room.data.OrthRoomObject;
import com.threerings.orth.room.data.PetInfo;
import com.threerings.orth.room.data.PlayerInfo;
import com.threerings.orth.room.data.FurniData;
import com.threerings.orth.world.client.WorldContext;

/**
 * Handles the loading of various media.
 */
public class MediaDirector extends BasicDirector
{
    public static const log :Log = Log.getLog(MediaDirector);

    public function MediaDirector (ctx :WorldContext)
    {
        super(ctx);
        _wctx = ctx;

        ctx.getLocationDirector().addLocationObserver(new LocationAdapter(null, locationDidChange));
    }

    /**
     * Creates an occupant sprite for the specified occupant info.
     *
     * @param extraInfo not yet defined, but an object from which to cull additional info
     */
    public function getSprite (occInfo :OccupantInfo, extraInfo :Object) :OccupantSprite
    {
        if (occInfo is PlayerInfo) {
            var isOurs :Boolean = _wctx.getMyName().equals(occInfo.username);
            if (isOurs && _ourAvatar != null) {
                _ourAvatar.setOccupantInfo(occInfo, extraInfo);
                return _ourAvatar;
            }
            var sprite :MemberSprite = new MemberSprite(_wctx, occInfo as PlayerInfo, extraInfo);
            if (isOurs) {
                _ourAvatar = sprite;
            }
            return sprite;

        } else if (occInfo is PetInfo) {
            return new PetSprite(_wctx, occInfo as PetInfo, extraInfo);

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
        return new FurniSprite(_wctx, furni);
    }

    /**
     * Get a Decor sprite for the specified decor data, caching as appropriate.
     */
    public function getDecor (decor :Decor) :DecorSprite
    {
        return new DecorSprite(_wctx, decor);
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

    /** A casted copy of the context. */
    protected var _wctx :WorldContext;

    /** Our very own avatar: avoid loading and unloading it. */
    protected var _ourAvatar :MemberSprite;
}
}
