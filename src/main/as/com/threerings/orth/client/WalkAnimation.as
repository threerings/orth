//
// $Id: WalkAnimation.as 17626 2009-07-21 21:43:56Z mdb $

package com.threerings.orth.client {

import com.threerings.display.AnimationImpl;

import com.threerings.orth.room.client.OccupantSprite;
import com.threerings.orth.room.data.OrthLocation;
import com.threerings.orth.room.data.OrthScene;

/**
 * Handles moving an occupant sprite around in a scene.
 */
public class WalkAnimation extends AnimationImpl
{
    public function WalkAnimation (
        spr :OccupantSprite, scene :OrthScene, src :OrthLocation, dest :OrthLocation)
    {
        _sprite = spr;
        _source = [ src.x, src.y, src.z, src.orient ];
        _dest = [ dest.x, dest.y, dest.z, dest.orient ];

        var dx :Number = scene.getWidth() * (dest.x - src.x);
        var dy :Number = scene.getHeight() * (dest.y - src.y);
        var dz :Number = scene.getDepth() * (dest.z - src.z);

        // calculate the duration- walk speed is specified in pixels/second.
        _duration = int(1000 * Math.sqrt((dx * dx) + (dy * dy) + (dz * dz)) /
            spr.getMoveSpeed(scene.getDecorInfo().getActorScale()));
    }

    /**
     * Update the actor's location based on the time elapsed.
     */
    override public function updateAnimation (elapsed :Number) :void
    {
        if (elapsed >= _duration) {
            // golly, we're done!
            _sprite.setLocation(_dest);
            _sprite.walkCompleted(_dest[3] as Number); // orient
            stopAnimation();
            return;
        }

        // otherwise calculate the intermediate location
        var current :Array = [];
        for (var ii :int = 0; ii < 3; ii++) { // don't do orient
            current[ii] = moveFunction(elapsed, _source[ii],
                _dest[ii] - _source[ii], _duration);
        }
        _sprite.setLocation(current);
    }

    /**
     * The easing function we use to move objects around the scene.
     */
    protected static function moveFunction (
        stamp :int, initial :Number, delta :Number, duration :int) :Number
    {
        return ((delta * stamp) / duration) + initial;
    }

    /** The sprite we'll be moving. */
    protected var _sprite :OccupantSprite;

    /** The source location. */
    protected var _source :Array;

    /** The destination location. */
    protected var _dest :Array;

    /** The amount of time we'll spend moving. */
    protected var _duration :int;
}
}
