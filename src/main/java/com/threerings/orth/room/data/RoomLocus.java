package com.threerings.orth.room.data;

import com.samskivert.util.Comparators;

import com.threerings.orth.locus.data.Locus;

public class RoomLocus extends Locus
    implements Comparable<RoomLocus>
{
    public int sceneId;

    public RoomLocus ()
    {
    }

    public RoomLocus (int sceneId)
    {
        this.sceneId = sceneId;
    }

    @Override public int compareTo (RoomLocus other)
    {
        return Comparators.compare(sceneId, other.sceneId);
    }
}
