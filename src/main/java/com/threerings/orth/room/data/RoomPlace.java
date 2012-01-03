//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.room.data;

import com.threerings.whirled.data.ScenePlace;

public class RoomPlace extends ScenePlace
{
    /** The instance this room is hosted on, or else just the peer name. */
    public String instanceId;

    /** The name of this room. */
    public String name;

    public RoomPlace (String instanceId, int sceneOid, int sceneId, String name)
    {
        super(sceneOid, sceneId);
        this.instanceId = instanceId;
        this.name = name;
    }

    @Override
    public String toString ()
    {
        return "Room<" + name + ", " + instanceId + ", " + sceneId + ">";
    }

    @Override
    public int hashCode ()
    {
        return sceneId;
    }

    @Override
    public boolean equals (Object other)
    {
        return (other instanceof RoomPlace) &&
            ((RoomPlace) other).instanceId.equals(instanceId) &&
            ((RoomPlace) other).sceneId == sceneId;
    }
}
