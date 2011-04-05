//
// $Id$

package com.threerings.orth.locus.data;

import com.threerings.io.SimpleStreamableObject;
import com.threerings.presents.dobj.DSet;

public final class HostedLocus extends SimpleStreamableObject
    implements DSet.Entry
{
    public Locus locus;
    public String host;
    public int[] ports;

    public HostedLocus (Locus locus, String host, int[] ports)
    {
        this.locus = locus;
        this.host = host;
        this.ports = ports;
    }

    @Override
    public Comparable<?> getKey ()
    {
        return locus.getId();
    }
}
