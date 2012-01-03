//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.nodelet.server;

import com.google.inject.Inject;

import com.samskivert.util.ResultListener;

import com.threerings.presents.client.InvocationService;
import com.threerings.presents.peer.data.NodeObject;
import com.threerings.presents.peer.server.PeerManager.NodeRequest;

import com.threerings.orth.data.AuthName;
import com.threerings.orth.nodelet.data.HostedNodelet;
import com.threerings.orth.nodelet.data.Nodelet;
import com.threerings.orth.peer.data.OrthNodeObject;
import com.threerings.orth.peer.server.OrthPeerManager;

import static com.threerings.orth.Log.log;

/**
 * A node request that is used in load balancing, instructing some given peer to host
 * some given nodelet. Its juicy core is {@link #hostLocally}, which must be defined by
 * any concrete subclass and which does the actual registering.
 */
public abstract class HostNodeletRequest extends NodeRequest
{
    public HostNodeletRequest (AuthName user, String dsetName, Nodelet nodelet)
    {
        _user = user;
        _dsetName = dsetName;
        _nodelet = nodelet;
    }

    @Override public boolean isApplicable (NodeObject nodeObject)
    {
        // will never be called, as we use _peerMan.invokeRequest(peer, request, listener)
        return true;
    }

    @Override protected void execute (final InvocationService.ResultListener listener) {
        final NodeObject.Lock lock = new NodeObject.Lock(getLockName(), _nodelet.getKey());
        _peerMan.acquireLock(lock, new ResultListener<String>() {
            @Override public void requestCompleted (String nodeName) {
                if (_peerMan.getNodeObject().nodeName.equals(nodeName)) {
                    log.info("Got nodelet", "nodelet", _nodelet);
                    hostNodelet();

                } else {
                    // we didn't get the lock, so let's see what happened by re-checking
                    HostedNodelet hosted = _peerMan.findHostedNodelet(_dsetName, _nodelet);
                    if (hosted != null) {
                        listener.requestProcessed(hosted);
                        return;
                    }

                    log.warning("Couldn't get lock and couldn't find nodelet on other node!",
                        "nodelet", _nodelet, "nodeName", nodeName);
                    listener.requestFailed("Whacked Out Node");
                }
            }

            @Override public void requestFailed (Exception cause) {
                log.warning("Couldn't get nodelet lock!", "nodelet", _nodelet, cause);
            }

            protected void hostNodelet () {
                try {
                    hostLocally(_user, _nodelet, new ResultListener<HostedNodelet>() {
                        @Override public void requestCompleted (HostedNodelet result) {
                            OrthNodeObject node = ((OrthNodeObject)_peerMan.getNodeObject());
                            node.addToSet(_dsetName, result);
                            listener.requestProcessed(result);
                            _peerMan.releaseLock(lock, new NOOP<String>());
                        }

                        @Override public void requestFailed (Exception cause) {
                            log.warning("Couldn't host nodelet!", "nodelet", _nodelet, cause);
                            _peerMan.releaseLock(lock, new NOOP<String>());
                        }
                    });

                } catch (RuntimeException re) {
                    _peerMan.releaseLock(lock, new NOOP<String>());
                    throw re;
                }
            }
        });
    }

    /**
     * Gets the name of the peer system lock to use in performing nodelet resolution.
     */
    protected String getLockName ()
    {
        return _dsetName + "Lock";
    }

    /**
     * Hosts the given nodelet locally and provides the listener with the result.
     */
    protected abstract void hostLocally (AuthName caller, Nodelet nodelet,
            ResultListener<HostedNodelet> listener);

    protected AuthName _user;
    protected String _dsetName;
    protected Nodelet _nodelet;

    @Inject protected transient OrthPeerManager _peerMan;
}
