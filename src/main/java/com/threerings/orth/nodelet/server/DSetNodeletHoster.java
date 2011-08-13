//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.nodelet.server;

import java.util.List;

import com.google.common.base.Function;
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
import com.threerings.presents.peer.data.NodeObject;

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

        // our load balancing strategy is very simple; we define the load of a peer as
        // the number of clients currently connected to it. while all sorts of more complex
        // expressions can be imagined, this one is probably about as good as any other in
        // capturing the general business of a server -- at least until such a day as we get

        float minLoad = -1;
        String chosenPeer = null;
        for (NodeObject obj : _peerMan.getNodeObjects()) {
            float load = ((OrthNodeObject) obj).calculateLoad();
            if (obj.nodeName.equals(_peerMan.getNodeObject().nodeName)) {
                // if there's no great difference in loads, prefer to host it locally
                load *= 0.9;
            }
            if (load < minLoad || minLoad < 0) {
                chosenPeer = obj.nodeName;
                minLoad = load;
            }
        }

        // a simple listener forwarder - curse the narya/samskivert confusion!
        InvocationService.ResultListener peerListener = new InvocationService.ResultListener() {
            @Override public void requestProcessed (Object result) {
                listener.requestCompleted((HostedNodelet) result);
            }
            @Override public void requestFailed (String cause) {
                listener.requestFailed(new RuntimeException(cause));
            }
        };

        _peerMan.invokeNodeRequest(chosenPeer, createHostingRequest(
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
