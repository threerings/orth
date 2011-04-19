package com.threerings.orth.nodelet.server;

import com.google.inject.Inject;

import com.samskivert.util.ResultListener;

import com.threerings.orth.data.AuthName;
import com.threerings.orth.nodelet.data.HostedNodelet;
import com.threerings.orth.nodelet.data.Nodelet;
import com.threerings.orth.peer.data.OrthNodeObject;
import com.threerings.orth.peer.server.OrthPeerManager;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.peer.data.NodeObject;

import static com.threerings.orth.Log.log;

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
    public DSetNodeletHoster (String dsetName)
    {
        _dsetName = dsetName;
    }

    public void resolveHosting (final ClientObject caller, final Nodelet nodelet,
            final ResultListener<HostedNodelet> listener)
    {
        if (hostExisting(nodelet, listener)) {
             return;
        }

        // ORTH TODO: At this point we know the nodelet needs to be hosted. For now, we will
        // resolve it locally, but what should really happen here is that the nodes should
        // all be queried to see which peer is the least loaded and the request should
        // be punted to there.

        final NodeObject.Lock lock = new NodeObject.Lock(getLockName(), nodelet.getId());
        _peerMan.acquireLock(lock, new ResultListener<String>() {
            @Override public void requestCompleted (String nodeName) {
                if (_peerMan.getNodeObject().nodeName.equals(nodeName)) {
                    log.info("Got nodelet", "nodelet", nodelet);
                    hostNodelet();
    
                } else {
                    // we didn't get the lock, so let's see what happened by re-checking
                    if (!hostExisting(nodelet, listener)) {
                        log.warning("Couldn't get lock and couldn't find nodelet on other node!",
                            "nodelet", nodelet, "nodeName", nodeName);
                        listener.requestFailed(new Exception("Whacked Out Node"));
                    }
                }
            }

            protected void hostNodelet () {
                try {
                    AuthName user = (AuthName)caller.username;
                    hostLocally(user, nodelet, new ResultListener<HostedNodelet>() {
                        @Override public void requestCompleted (HostedNodelet result) {
                            OrthNodeObject node = ((OrthNodeObject)_peerMan.getNodeObject());
                            node.addToSet(_dsetName, result);
                            listener.requestCompleted(result);
                            _peerMan.releaseLock(lock, new ResultListener.NOOP<String>());
                        }

                        @Override public void requestFailed (Exception cause) {
                            log.warning("Couldn't host nodelet!", "nodelet", nodelet, cause);
                            _peerMan.releaseLock(lock, new ResultListener.NOOP<String>());
                        }
                    });

                } catch (RuntimeException re) {
                    _peerMan.releaseLock(lock, new ResultListener.NOOP<String>());
                    throw re;
                }
            }

            @Override
            public void requestFailed (Exception cause) {
                log.warning("Couldn't get nodelet lock!", "nodelet", nodelet, cause);
            }
        });
    }

    /**
     * Attempts to materialize a nodelet performing only a lookup on the nodelet within the
     * peer system (no actual resolution of the nodelet's content, manager or DObject).
     */
    protected boolean hostExisting (Nodelet nodelet, ResultListener<HostedNodelet> listener)
    {
        HostedNodelet hosted = _peerMan.findHostedNodelet(_dsetName, nodelet);
        if (hosted != null) {
            listener.requestCompleted(hosted);
            return true;
        }
        return false;
    }

    /**
     * Gets the name of the peer system lock to use in performing nodelet resolution.
     */
    protected String getLockName ()
    {
        return _dsetName + "Lock";
    }

    /**
     * Host the given nodelet locally and provide the listener with the result.
     */
    protected abstract void hostLocally (AuthName caller, Nodelet nodelet,
            ResultListener<HostedNodelet> listener);

    /** The name of the dset governing our hosted nodelet instances in the OrthNodeObject. */
    protected String _dsetName;

    // dependencies
    @Inject protected OrthPeerManager _peerMan;
}
