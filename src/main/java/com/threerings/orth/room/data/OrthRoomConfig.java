//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.room.data;

import com.threerings.crowd.data.PlaceConfig;

/**
 * Exist merely to point at the right manager.
 */
public class OrthRoomConfig extends PlaceConfig
{
    public String getManagerClassName ()
    {
        return "com.threerings.orth.room.server.OrthRoomManager";
    }
}
