//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.room.data;

import com.threerings.orth.locus.data.Locus;
import com.threerings.orth.nodelet.data.Nodelet;

public class RoomLocus extends Nodelet
    implements Locus
{
    public int sceneId;
    public OrthLocation loc;

    public RoomLocus (int sceneId, OrthLocation loc)
    {
        this.sceneId = sceneId;
        this.loc = loc;
    }

    @Override
    public Comparable<?> getKey ()
    {
        return sceneId;
    }

    @Override public int hashCode ()
    {
        return sceneId;
    }

    @Override public boolean equals (Object other)
    {
        return (other instanceof RoomLocus) && sceneId == ((RoomLocus) other).sceneId;
    }
}
