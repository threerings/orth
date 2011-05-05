//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.
package com.threerings.orth.room.data;

import com.threerings.orth.locus.data.Locus;
import com.threerings.orth.nodelet.data.Nodelet;

public class RoomLocus extends Locus
    implements Nodelet.Publishable
{
    public int sceneId;

    public RoomLocus (int sceneId)
    {
        this.sceneId = sceneId;
    }

    @Override
    public Comparable<?> getKey ()
    {
        return sceneId;
    }
}
