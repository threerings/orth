package com.threerings.orth.nodelet.server;

import com.threerings.orth.nodelet.data.HostedNodelet;
import com.threerings.presents.dobj.DObject;

/**
 * Manages a nodelet DObject.
 * TODO: should a NodeletObject hierarchy also be created?
 */
public class NodeletManager
{
    /**
     * Initializes the manager with the given objects. Called by {@code NodeletRegistry} when
     * setting up the manager.
     */
    public void init (NodeletRegistry registry, HostedNodelet nodelet, DObject obj)
    {
        _registry = registry;
        _nodelet = nodelet;
        _sharedObject = obj;
    }

    /**
     * Called by the {@link NodeletRegistry} after {@link #init()}. Does nothing by default.
     */
    public void didInit ()
    {
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
     * Stops managing. This should <em>only</em> be called by {@link
     * NodeletRegistry#shutdownManager()}. That method will also take care of destroying the shared
     * object and clearing the invocation dispatcher for the service. So this method only needs to
     * clean up its non-generic structures, if any. By default, does nothing.
     */
    public void shutdown ()
    {
    }

    /**
     * Gets the nodelet whose object we manage.
     */
    public HostedNodelet getNodelet ()
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

    protected NodeletRegistry _registry;
    protected HostedNodelet _nodelet;
    protected DObject _sharedObject;
}
