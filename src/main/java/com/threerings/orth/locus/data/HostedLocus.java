package com.threerings.orth.locus.data;

import com.threerings.io.SimpleStreamableObject;

public class HostedLocus extends SimpleStreamableObject
{
    public Locus locus;
    public String host;
    public int[] ports;

    public HostedLocus () {} // This HostedLocus is just streamy!

    public HostedLocus (Locus locus, String host, int[] ports)
    {
        this.locus = locus;
        this.host = host;
        this.ports = ports;
    }
}
