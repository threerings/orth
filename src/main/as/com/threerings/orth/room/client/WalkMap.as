//
// Who - Copyright 2010-2011 Three Rings Design, Inc.
package com.threerings.orth.room.client
{
import flash.geom.Point;

import com.threerings.display.DisplayUtil;

import com.threerings.orth.room.client.layout.RoomLayout;
import com.threerings.orth.room.data.OrthLocation;
import com.threerings.orth.room.data.OrthRoomCodes;
import com.threerings.orth.ui.ObjectMediaDesc;

/**
 * Contains methods for walkability calculations.
 */
public class WalkMap extends RoomElementSprite
{
    public function WalkMap (layout :RoomLayout)
    {
        this.mouseEnabled = false;
        this.visible = false;

        _layout = layout;
        _loc.z = 1.0;
    }

    public function set desc (desc :ObjectMediaDesc) :void
    {
        DisplayUtil.removeAllChildren(this);
        _desc = desc;
        if (_desc != null) {
            this.addChild(desc.getMediaObject());
        }
    }

    public function get desc () :ObjectMediaDesc
    {
        return _desc;
    }

    public function getLastWalkablePoint (myLoc :OrthLocation, toLoc :OrthLocation) :OrthLocation
    {
        if (myLoc == null || toLoc == null || _desc == null) {
            return null;
        }

        const from :Point = localToGlobal(_layout.metrics.roomToScreen(myLoc.x, myLoc.y, myLoc.z));
        const to :Point = localToGlobal(_layout.metrics.roomToScreen(toLoc.x, toLoc.y, toLoc.z));

        const n :int = Point.distance(from, to);
        var ii :int = 0;
        // if we're stuck and trying to get out, scan ahead to the first walkable point
        while (!isWalkable(ii)) {
            if (ii >= n) {
                // not a single walkable point: they are utterly stuck, allow anything
                return toLoc;
            }
            ii ++;
        }

        // if we get here, ii represents a walkable point; see how far we can walk from there
        while (isWalkable(ii)) {
            if (ii >= n) {
                // we were able to walk all the way to the end, hurray
                return toLoc;
            }
            ii ++;
        }

        // else figure out how far we got
        const lastPoint :Point = Point.interpolate(from, to, (n-(ii-1))/n);
        const lastLoc :ClickLocation = _layout.pointToAvatarLocation(lastPoint.x, lastPoint.y);
        return (lastLoc != null) ? lastLoc.loc : null;

        function isWalkable (ii :Number) :Boolean {
            // note that Point's interpolate()'s third argument goes from 1 to 0 (!?)
            const toTest :Point = Point.interpolate(from, to, (n-ii)/n);
            return hitTestPoint(toTest.x, toTest.y, true);
        }
    }

    public function isLocationWalkable (loc :OrthLocation) :Boolean
    {
        const point :Point = localToGlobal(_layout.metrics.roomToScreen(loc.x, loc.y, loc.z));
        return (point == null) || hitTestPoint(point.x, point.y, true);
    }

    // from RoomElement
    override public function getLayoutType () :int
    {
        return OrthRoomCodes.LAYOUT_PARALLAX;
    }

    protected var _desc :ObjectMediaDesc;
    protected var _layout :RoomLayout;
}
}
