//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.nodelet.server;

import com.google.common.base.Preconditions;
import com.google.inject.Inject;

import com.samskivert.util.ResultListener;

import com.threerings.orth.data.AuthName;
import com.threerings.orth.nodelet.data.HostedNodelet;
import com.threerings.orth.nodelet.data.Nodelet;
import com.threerings.orth.peer.data.OrthNodeObject;
import com.threerings.orth.peer.server.OrthPeerManager;

import com.threerings.presents.client.InvocationService;
import com.threerings.presents.data.ClientObject;

/**
 * Implement hosting for nodelets, assuming said hosting is governed by a DSet in
 * OrthNodeObject. Delegates the actual instantiation of a nodelet to a subclass.
 */
public abstract class DSetNodeletHoster
    implements NodeletRegistry.NodeletHoster
{
    /**
     * Creates a new nodelet registry governed by the dset with the given name.
     * @see OrthNodeObject
     */
    public DSetNodeletHoster (String dsetName, Class<? extends Nodelet> nclass)
    {
        _dsetName = dsetName;
        _nodeletClass = nclass;
    }

    public String getDSetName ()
    {
        return _dsetName;
    }

    public void resolveHosting (final ClientObject caller, final Nodelet nodelet,
            final ResultListener<HostedNodelet> listener)
    {
        Preconditions.checkArgument(_nodeletClass.isInstance(nodelet));

        HostedNodelet hosted = _peerMan.findHostedNodelet(_dsetName, nodelet);
        if (hosted != null) {
            listener.requestCompleted(hosted);
            return;
        }

        // ORTH TODO: At this point we know the nodelet needs to be hosted. For now, we will
        // resolve it locally, but what should really happen here is that the nodes should
        // all be queried to see which peer is the least loaded and the request should
        // be punted to there.
        String peer = _peerMan.getNodeObject().nodeName;

        // a simple listener forwarder - curse the narya/samskivert confusion!
        InvocationService.ResultListener peerListener = new InvocationService.ResultListener() {
            @Override public void requestProcessed (Object result) {
                listener.requestCompleted((HostedNodelet) result);
            }
            @Override public void requestFailed (String cause) {
                listener.requestFailed(new RuntimeException(cause));
            }
        };

        _peerMan.invokeNodeRequest(peer, createHostingRequest(
            (AuthName) caller.username, nodelet), peerListener);
    }

    /** Overridden to instantiate the appropriate concrete {@link HostNodeletRequest}. */
    abstract protected HostNodeletRequest createHostingRequest (AuthName caller, Nodelet nodelet);

    /** The name of the dset governing our hosted nodelet instances in the OrthNodeObject. */
    protected String _dsetName;
    protected Class<? extends Nodelet> _nodeletClass;

    // dependencies
    @Inject protected OrthPeerManager _peerMan;
}
