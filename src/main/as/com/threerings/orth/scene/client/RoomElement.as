//
// $Id: RoomElement.as 15000 2009-02-24 00:24:42Z mdb $

package com.threerings.orth.scene.client {

import com.threerings.orth.client.Snapshottable;

import com.threerings.orth.scene.data.OrthLocation;

/**
 * Interface for all objects that exist in a scene, and have both scene location in room
 * coordinate space, and screen location that needs to be updated appropriately.
 */
public interface RoomElement extends Snapshottable
{
    /**
     * Return the type of layout to do for this element.
     *
     * @return probably RoomCodes.LAYOUT_NORMAL.
     */
    function getLayoutType () :int

    /**
     * Return the layer upon which this element should be layed out.
     *
     * @return probably RoomCodes.FURNITURE_LAYER.
     */
    function getRoomLayer () :int;

    /**
     * Set the logical location of the element. The orientation is not updated.
     * @param newLoc may be an OrthLocation or an Array.
     */
    function setLocation (newLoc :Object) :void

    /**
     * Get the logical location of this object.
     */
    function getLocation () :OrthLocation;

    /**
     * Is this element important enough that it should appear in front of other RoomElements
     * that have the exact same layer and z position?
     */
    function isImportant () :Boolean;

    /**
     * Set the screen location of the object, based on its location in the scene.
     */
    function setScreenLocation (x :Number, y :Number, scale :Number) :void;
}
}
