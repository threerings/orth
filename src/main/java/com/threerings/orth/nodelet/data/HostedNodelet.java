//
// $Id$

package com.threerings.orth.nodelet.data;

import com.threerings.io.SimpleStreamableObject;
import com.threerings.presents.dobj.DSet;

public final class HostedNodelet extends SimpleStreamableObject
    implements DSet.Entry
{
    public Nodelet nodelet;
    public String host;
    public int[] ports;

    public HostedNodelet (Nodelet nodelet, String host, int[] ports)
    {
        this.nodelet = nodelet;
        this.host = host;
        this.ports = ports;
    }

    /**
     * Gets the id of the nodelet being hosted.
     */
    public int getId ()
    {
        return nodelet.getId();
    }

    @Override
    public Comparable<?> getKey ()
    {
        return nodelet.getId();
    }
}
