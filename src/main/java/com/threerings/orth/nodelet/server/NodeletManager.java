package com.threerings.orth.nodelet.server;

import com.threerings.presents.dobj.DObject;

/**
 * Manages a nodelet DObject.
 * TODO: should a NodeletObject hierarchy also be created?
 */
public class NodeletManager
{
    /**
     * Initializes the manager with the given object.
     */
    public void init (DObject obj)
    {
        _sharedObject = obj;
    }

    /**
     * Stops managing.
     */
    public void shutdown ()
    {
    }

    /**
     * Gets the object that we manage.
     */
    public DObject getSharedObject ()
    {
        return _sharedObject;
    }

    protected DObject _sharedObject;
}
