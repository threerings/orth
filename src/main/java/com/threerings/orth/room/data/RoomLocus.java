//
// $Id$

package com.threerings.orth.room.data;

import com.threerings.orth.locus.data.Locus;

public class RoomLocus extends Locus
{
    public int sceneId;

    public RoomLocus (int sceneId)
    {
        this.sceneId = sceneId;
    }
}
