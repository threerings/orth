package com.threerings.orth.nodelet.server;

import com.threerings.orth.nodelet.data.Nodelet;
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
    public void init (Nodelet nodelet, DObject obj)
    {
        _nodelet = nodelet;
        _sharedObject = obj;
    }

    /**
     * Allows the manager to perform more intialization such as loading persistent data before
     * publishing the hosted nodelet (opening the flood gates). Returns true is some asynchronous
     * work was queued and the caller should wait for the result.
     */
    public boolean prepare (com.samskivert.util.ResultListener<Void> rl)
    {
        return false;
    }

    /**
     * Stops managing.
     */
    public void shutdown ()
    {
    }

    /**
     * Gets the nodelet whose object we manage.
     */
    public Nodelet getNodelet ()
    {
        return _nodelet;
    }

    /**
     * Gets the object that we manage.
     */
    public DObject getSharedObject ()
    {
        return _sharedObject;
    }

    protected Nodelet _nodelet;
    protected DObject _sharedObject;
}
