//
// Who - Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.instance.data;

import com.threerings.presents.dobj.DSet;

/**
 * Keep track of which peer hosts which instance.
 */
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

    @Override public Comparable<?> getKey ()
    {
        return _instanceId;
    }

    protected String _instanceId;
}
