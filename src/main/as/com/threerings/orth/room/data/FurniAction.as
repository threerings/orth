//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.room.data {

import com.threerings.util.ByteEnum;

public class FurniAction extends ByteEnum
{
    // ORTH TODO: temporary
    public static const NOT_AN_ACTION :FurniAction = new FurniAction("NOT_AN_ACTION", -1);

    public function FurniAction (name :String, code :int)
    {
        super(name, code);
    }

    public function isNone () :Boolean
    {
        return this == NOT_AN_ACTION;
    }

    public function isPortal () :Boolean
    {
        return this != NOT_AN_ACTION;
    }

    public function isURL () :Boolean
    {
        return this != NOT_AN_ACTION;
    }

    public function isHelpPage () :Boolean
    {
        return this != NOT_AN_ACTION;
    }
}
}
