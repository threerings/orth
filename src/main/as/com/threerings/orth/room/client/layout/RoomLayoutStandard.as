//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.room.client.layout {
import flash.display.DisplayObject;
import flash.geom.Point;

import com.threerings.geom.Vector3;

import com.threerings.util.Log;

import com.threerings.orth.entity.client.ActorSprite;
import com.threerings.orth.entity.client.FurniSprite;
import com.threerings.orth.room.client.ClickLocation;
import com.threerings.orth.room.client.RoomElement;
import com.threerings.orth.room.client.RoomMetrics;
import com.threerings.orth.room.client.RoomView;
import com.threerings.orth.room.data.Decor;
import com.threerings.orth.room.data.OrthLocation;
import com.threerings.orth.room.data.OrthRoomCodes;

/**
 * This class factors out room layout math that converts between 3D room coordinate space
 * and screen coordinates.
 */
public class RoomLayoutStandard implements RoomLayout
{
    /** Chat history should be at least 50px tall, even in rooms with low horizon. */
    public static const MIN_CHAT_HEIGHT :Number = 50;

    /** Constructor. */
    public function RoomLayoutStandard (view :RoomView)
    {
        _parentView = view;
        _metrics = new RoomMetrics();
    }

    // from interface RoomLayout
    public function update (data :Decor) :void
    {
        _decor = data;
        _metrics.update(data);
    }

    // from interface RoomLayout
    public function get metrics () :RoomMetrics
    {
        return _metrics;
    }

    // from interface RoomLayout
    public function pointToAvatarLocation (
        stageX :Number, stageY :Number, anchorPoint :Object = null,
        anchorAxis :Vector3 = null, clampToRoom :Boolean = true) :ClickLocation
    {
        var loc :ClickLocation = pointToLocation(
            stageX, stageY, anchorPoint, anchorAxis, clampToRoom);
        return (loc.click == ClickLocation.FLOOR) ? loc : null;
    }

    // from interface RoomLayout
    public function pointToFurniLocation (
        stageX :Number, stageY :Number, anchorPoint :Object = null,
        anchorAxis :Vector3 = null, clampToRoom :Boolean = true) :ClickLocation
    {
        return pointToLocation(stageX, stageY, anchorPoint, anchorAxis, clampToRoom);
    }

    // from interface RoomLayout
    public function pointToLocationAtDepth (
        stageX :Number, stageY :Number, depth :Number) :OrthLocation
    {
        // get click location, in screen coords
        var p :Point = new Point(stageX, stageY);
        p = _parentView.globalToLocal(p);

        // let's make an anchor point
        var anchor :Vector3 = new Vector3(0, 0, depth);

        // find the intersection of the line of sight with the plane
        var cloc :ClickLocation = _metrics.screenToWallPlaneProjection(p.x, p.y, anchor);

        return (cloc != null) ? cloc.loc : null;
    }

    // from interface RoomLayout
    public function pointToLocationAtHeight (
        stageX :Number, stageY :Number, height :Number) :OrthLocation
    {
        // get click location, in screen coords
        var p :Point = new Point(stageX, stageY);
        p = _parentView.globalToLocal(p);

        // let's make an anchor point
        var anchor :Vector3 = new Vector3(0, height, 0);

        // find the intersection of the line of sight with the plane
        var cloc :ClickLocation = _metrics.screenToFloorPlaneProjection(p.x, p.y, anchor);

        return (cloc != null) ? cloc.loc : null;
    }

    /**
     * Turn the screen coordinate into an OrthLocation, with the orient field set to 0.
     */
    protected function pointToLocation (
        globalX :Number, globalY :Number, anchorPoint :Object = null,
        anchorAxis :Vector3 = null, clampToRoom :Boolean = true) :ClickLocation
    {
        // get click location, in screen coords
        var p :Point = new Point(globalX, globalY);
        p = _parentView.globalToLocal(p);

        var cloc :ClickLocation;
        if (anchorPoint == null) {
            // find the intersection of the line of sight with the first available wall.
            cloc = _metrics.screenToInnerWallsProjection(p.x, p.y);

        } else {
            var anchorLocation :Vector3;

            if (anchorPoint is Point) {
                // the constraint is a point on screen - convert it
                var pp :Point = _parentView.globalToLocal(anchorPoint as Point);
                var constLocation :ClickLocation =
                    _metrics.screenToInnerWallsProjection(pp.x, pp.y);

                anchorLocation = _metrics.toVector3(constLocation.loc);

            } else if (anchorPoint is OrthLocation) {
                // the constraint is a room location - we're ready to go!
                anchorLocation = _metrics.toVector3(anchorPoint as OrthLocation);

            } else {
                throw new ArgumentError("Invalid constraint argument type");
            }

            // which constraint operation are we using?
            var fn :Function = null;
            switch (anchorAxis) {
            case RoomMetrics.N_RIGHT: fn = _metrics.screenToXLineProjection; break;
            case RoomMetrics.N_UP:    fn = _metrics.screenToYLineProjection; break;
            case RoomMetrics.N_AWAY:  fn = _metrics.screenToZLineProjection; break;
            default:
                throw new ArgumentError("Unsupported anchorAxis type: " + anchorAxis);
            }

            // now find a point on the constraint line pointed to by the mouse
            var cLocation :Vector3 = fn(p.x, p.y, anchorLocation);
            if (clampToRoom) {
                cLocation = cLocation.clampToUnitBox();
            }

            // we're done - make a fake "floor" location
            cloc = new ClickLocation(ClickLocation.FLOOR, _metrics.toOrthLocation(cLocation));
        }

        if (clampToRoom) {
            clampClickLocation(cloc);
        }

        return cloc;
    }

    /** Clamps a click location to be inside the unit box. */
    protected function clampClickLocation (cloc :ClickLocation) :void
    {
        cloc.loc.x = Math.min(Math.max(cloc.loc.x, 0), 1);
        cloc.loc.y = Math.min(Math.max(cloc.loc.y, 0), 1);
        cloc.loc.z = Math.min(Math.max(cloc.loc.z, 0), 1);
    }

    // from interface RoomLayout
    public function locationToPoint (location :OrthLocation) :Point
    {
        return _metrics.roomToScreen(location.x, location.y, location.z);
    }

    // from interface RoomLayout
    public function updateScreenLocation (target :RoomElement, offset :Point = null) :void
    {
        var disp :DisplayObject = target.getVisualization();
        var loc :OrthLocation = target.getLocation();

        if (offset == null) {
            offset = NO_OFFSET;
        }

        switch (target.getLayoutType()) {
        default:
            Log.getLog(this).warning("Unknown layout type: " + target.getLayoutType() +
                ", falling back to LAYOUT_NORMAL.");
            // fall through to LAYOUT_NORMAL

        case OrthRoomCodes.LAYOUT_PARALLAX:
            // parallax layout is exactly as normal, except we pretend z is 0
            var z :Number = loc.z;
            loc = new OrthLocation(loc.x, loc.y, 0);

            // counter the scrolling depending on the z-depth of the sprite, where at 1.0
            // there no compensation; objects closer than that will actually scroll *more*
            // than the decor & scene as a whole
            if (z >= 0) {
                // we want z=oo to mean full offset
                // z=1 to mean zero offset
                // and z=0 to mean 50% negative offset
                // these conditions are satisfied by (1 - 3/(z+2))
                var scroll :Point = _parentView.getScrollOffset();
                offset.x -= scroll.x * (1 - 3/(z+2));
                offset.y -= scroll.y * (1 - 3/(z+2));
            }

            // finally fall through deliberately

        case OrthRoomCodes.LAYOUT_NORMAL:
            var screen :Point = _metrics.roomToScreen(loc.x, loc.y, loc.z);
            var scale :Number = _metrics.scaleAtDepth(loc.z) * getDecorScale(target);
            target.setScreenLocation(screen.x - offset.x, screen.y - offset.y, scale);
            break;
        }

        adjustZOrder(target);
    }

    /**
     * Adjust the z order of the specified sprite so that it is drawn according to its logical Z
     * coordinate relative to other sprites.
     */
    protected function adjustZOrder (element :RoomElement) :void
    {
        var sprite :DisplayObject = element.getVisualization();

        var dex :int;
        try {
            dex = _parentView.getChildIndex(sprite);
        } catch (er :Error) {
            // this can happen if we're resized during editing as we
            // try to reposition a sprite that's still in our data structures
            // but that has been removed as a child.
            return;
        }

        var newdex :int = dex;
        var cmp :int;
        // see if it should be moved behind
        while (newdex > 0) {
            cmp = compareRoomElement(newdex - 1, element);
            if (cmp >= 0) {
                break;
            }
            newdex--;
        }

        if (newdex == dex) {
            // see if it should be moved forward
            while (newdex < _parentView.numChildren - 1) {
                cmp = compareRoomElement(newdex + 1, element);
                if (cmp <= 0) {
                    break;
                }
                newdex++;
            }
        }

        if (newdex != dex) {
            _parentView.setChildIndex(sprite, newdex);
        }
    }

    protected function getDecorScale (element :RoomElement) :Number
    {
        if (element is ActorSprite) {
            return _decor.getActorScale();
        }
        if (element is FurniSprite) {
            return _decor.getFurniScale();
        }
        // other sprites could use furniScale, I suppose..
        return 1;
    }

    /**
     * Return -1 if the element at the specified index should be in front of
     * the comparison element, 1 if behind, or 0 to keep the same relative position.
     */
    protected function compareRoomElement (index :int, cmpElement :RoomElement) :int
    {
        var re :RoomElement = _parentView.vizToEntity(_parentView.getChildAt(index));
        if (re == null) {
            Log.getLog(this).warning("Non room element in room",
                "index", index, "numChildren", _parentView.numChildren,
                "displayObject", _parentView.getChildAt(index), new Error());
            return -1; // whatever it is, put it in front of everything
        }

        var layer :int = re.getRoomLayer();
        var cmpLayer :int = cmpElement.getRoomLayer();
        if (layer > cmpLayer) {
            return 1;
        } else if (layer < cmpLayer) {
            return -1;
        }

        // else, if on same layer, compare by Z
        var z :Number = re.getLocation().z;
        var cmpZ :Number = cmpElement.getLocation().z;
        if (z > cmpZ) {
            return 1;
        } else if (z < cmpZ) {
            return -1;
        }

        // else, if at same Z, compare by importance
        var imp :Boolean = re.isImportant();
        var cmpImportant :Boolean = cmpElement.isImportant();
        if (imp == cmpImportant) {
            return 0;
        }
        return imp ? -1 : 1;
    }

    /** Room metrics storage. */
    protected var _metrics :RoomMetrics;

    /** The decor. */
    protected var _decor :Decor;

    /** RoomView object that contains this instance. */
    protected var _parentView :RoomView;

    /** Point (0, 0) expressed as a constant. */
    protected static const NO_OFFSET :Point = new Point(0, 0);
}
}

