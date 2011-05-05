//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.room.data;

import com.threerings.whirled.data.ScenePlace;

public class RoomPlace extends ScenePlace
{
    /** The peer this room is hosted on. */
    public String peer;

    /** The name of this room. */
    public String name;

    public RoomPlace (String peer, int sceneOid, int sceneId, String name)
    {
        super(sceneOid, sceneId);
        this.peer = peer;
        this.name = name;
    }

    @Override
    public String toString ()
    {
        return "Room<" + name + ", " + peer + ", " + sceneId + ">";
    }

    @Override
    public int hashCode ()
    {
        return sceneId;
    }

    @Override
    public boolean equals (Object other)
    {
        return (other instanceof RoomPlace) && ((RoomPlace) other).peer.equals(peer) &&
            ((RoomPlace) other).sceneId == sceneId;
    }
}
