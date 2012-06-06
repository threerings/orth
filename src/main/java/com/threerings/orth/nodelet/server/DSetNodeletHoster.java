//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.nodelet.server;

import com.google.common.base.Function;
import com.google.common.base.Preconditions;
import com.google.common.collect.Ordering;
import com.google.inject.Inject;

import com.samskivert.util.ResultListener;

import com.threerings.util.Resulting;

import com.threerings.presents.data.ClientObject;
import com.threerings.presents.peer.data.NodeObject;
import com.threerings.presents.peer.server.PeerManager.NodeAction;

import com.threerings.orth.data.AuthName;
import com.threerings.orth.nodelet.data.HostedNodelet;
import com.threerings.orth.nodelet.data.Nodelet;
import com.threerings.orth.peer.data.OrthNodeObject;
import com.threerings.orth.peer.server.OrthPeerManager;

/**
 * Implement hosting for nodelets, assuming said hosting is governed by a DSet in
 * OrthNodeObject. Delegates the actual instantiation of a nodelet to a subclass.
 */
public abstract class DSetNodeletHoster
    implements NodeletRegistry.NodeletHoster
{
    /**
     * Creates a new nodelet registry governed by the DSet with the given name.
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

    @Override
    public void resolveHosting (final ClientObject caller, final Nodelet nodelet,
            final ResultListener<HostedNodelet> listener)
    {
        Preconditions.checkArgument(_nodeletClass.isInstance(nodelet));

        HostedNodelet hosted = _peerMan.findHostedNodelet(_dsetName, nodelet);
        if (hosted != null) {
            listener.requestCompleted(hosted);
            return;
        }
        _peerMan.invokeNodeRequest(determineHostingPeer(nodelet),
            createHostingRequest((AuthName) caller.username, nodelet),
            new Resulting<HostedNodelet>(listener));
    }

    @Override
    public void clearHosting (Nodelet nodelet)
    {
        final String dsetName = _dsetName;
        final Comparable<?> key = nodelet.getKey();
        _peerMan.invokeNodeAction(new NodeAction() {
            @Override public boolean isApplicable (NodeObject nodeobj) {
                return nodeobj.getSet(dsetName).containsKey(key);
            }
            @Override protected void execute () {
                _orthPeerMgr.getOrthNodeObject().removeFromSet(dsetName, key);
            }
            @Inject protected transient OrthPeerManager _orthPeerMgr;
        });
    }

    /**
     * The nodelet is about to be hosted; we need to determine which host to ask to do it.
     *
     * Subclasses may override this method and return an absolute decision that they come up
     * with however they like.
     *
     * Alternately, if they merely want to tweak the balancing decision, see
     * {@link #getHostingPeerScore(OrthNodeObject, Nodelet)}, which is what the default
     * implementation uses to find the least loaded (highest scoring) peer.
     */
    protected String determineHostingPeer (final Nodelet nodelet)
    {
        return Ordering.natural().onResultOf(new Function<OrthNodeObject, Comparable<?>>() {
            @Override public Comparable<?> apply (OrthNodeObject input) {
                return getHostingPeerScore(input, nodelet);
            }
        }).greatestOf(_peerMan.getOrthNodeObjects(), 1).get(0).nodeName;
    }

    /**
     * Return a peer's load balancing score, from 0.0 (absolutely full) to 1.0 (unloaded) or,
     * if subclassed, even higher to suggest an explicit hunger to host the given nodelet.
     *
     * Subclasses may modify or override this value for their own application specific purposes.
     * The default implementation is 1 / (1 + node.load), which will always lie in (0, 1].
     */
    protected float getHostingPeerScore (OrthNodeObject nodeObj, Nodelet nodelet)
    {
        return (float) (1.0 / (1.0 + Math.max(0, nodeObj.calculateLoad())));
    }

    /** Overridden to instantiate the appropriate concrete {@link HostNodeletRequest}. */
    abstract protected HostNodeletRequest createHostingRequest (AuthName caller, Nodelet nodelet);

    /** The name of the DSet governing our hosted nodelet instances in the OrthNodeObject. */
    protected String _dsetName;
    protected Class<? extends Nodelet> _nodeletClass;

    // dependencies
    @Inject protected OrthPeerManager _peerMan;
}
