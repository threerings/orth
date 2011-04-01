//
// $Id$

package com.threerings.orth.room.data;

import com.threerings.orth.locus.data.HostedLocus;
import com.threerings.presents.dobj.DSet;

public class HostedRoom extends HostedLocus implements DSet.Entry
{
    public HostedRoom ()
    {
    }

    public HostedRoom (RoomLocus locus, String host, int[] port)
    {
        super(locus, host, port);
    }

    @Override
    public Comparable<?> getKey ()
    {
        return (RoomLocus)locus;
    }
}
