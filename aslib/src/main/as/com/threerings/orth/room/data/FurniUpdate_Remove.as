//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.room.data {

/**
 * Represents the removal of furni from the room.
 */
public class FurniUpdate_Remove extends FurniUpdate
{
    // from FurniUpdate
    override protected function doUpdate (model :OrthSceneModel) :void
    {
        model.removeFurni(data);
    }
}
}
