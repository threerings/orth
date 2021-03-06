//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.room.data;

import com.samskivert.util.ByteEnum;

import com.threerings.io.Streamable;

public interface FurniAction extends ByteEnum, Streamable
{
    boolean isPortal ();

    boolean isURL ();
}
