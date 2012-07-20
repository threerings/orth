//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.room.data {

import flashx.funk.util.isAbstract;

import com.threerings.util.ByteEnum;

public class EntityType extends ByteEnum
{
    public static const NOT_A_TYPE :EntityType = new EntityType("NOT_A_TYPE", 0);

    public function EntityType (name :String, code :int)
    {
        super(name, code);
    }

    // ORTH TODO: see MSOY's RoomController.ENTITY_TYPES
    public function getPropertyType () :String
    {
        return isAbstract();
    }
}
}
