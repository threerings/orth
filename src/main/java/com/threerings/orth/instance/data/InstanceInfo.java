//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.instance.data;

import com.threerings.util.ActionScript;

import com.threerings.presents.dobj.DSet;

/**
 * Keep track of which peer hosts which instance.
 */
@ActionScript(omit=true)
public class InstanceInfo implements DSet.Entry
{
    public static Comparable<?> makeKey (String instanceId)
    {
        return instanceId;
    }

    public InstanceInfo (String instanceId)
    {
        _instanceId = instanceId;
    }

    public String getInstanceId ()
    {
        return _instanceId;
    }

    @Override public Comparable<?> getKey ()
    {
        return _instanceId;
    }

    protected String _instanceId;
}
