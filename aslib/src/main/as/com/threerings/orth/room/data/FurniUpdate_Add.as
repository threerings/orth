//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.room.data {

/**
 * Represents the addition of furniture to a room.
 */
public class FurniUpdate_Add extends FurniUpdate
{
    // from FurniUpdate
    override protected function doUpdate (model :OrthSceneModel) :void
    {
        model.addFurni(data);
    }
}
}
