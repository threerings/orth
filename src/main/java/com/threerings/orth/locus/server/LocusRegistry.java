package com.threerings.orth.locus.server;

import com.google.inject.Inject;

import com.samskivert.util.ResultListener;

import com.threerings.orth.locus.client.LocusService.LocusMaterializationListener;
import com.threerings.orth.locus.data.HostedLocus;
import com.threerings.orth.locus.data.Locus;
import com.threerings.orth.peer.data.OrthNodeObject;
import com.threerings.orth.peer.server.OrthPeerManager;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.peer.data.NodeObject;

import static com.threerings.orth.Log.log;

/**
 * Implement locus materialization, assuming the hosting of the locus is governed by a DSet in
 * OrthNodeObject. Delegates the actual instantiation of a locus to a subclass.
 */
public abstract class LocusRegistry
    implements LocusMaterializer
{
    /**
     * Creates a new locus registry governed by the dset with the given name.
     */
    public LocusRegistry (String dsetName)
    {
        _dsetName = dsetName;
    }

    @Override // from LocusMaterializer
    public void materializeLocus (ClientObject caller, final Locus locus,
        final LocusMaterializationListener listener)
    {
        if (materializeExistingLocus(listener, locus)) {
             return;
        }

        // ORTH TODO: At this point we know the locus needs to be hosted. For now, we will
        // resolve it locally, but what should really happen here is that the nodes should
        // all be queried to see which room peer is the least loaded and the request should
        // be punted to there.

        final NodeObject.Lock lock = new NodeObject.Lock(getLockName(), locus.getId());
        _peerMan.acquireLock(lock, new ResultListener<String>() {
            @Override public void requestCompleted (String nodeName) {
                if (_peerMan.getNodeObject().nodeName.equals(nodeName)) {
                    log.info("Got RoomLocus lock", "locus", locus);
                    hostLocus();
    
                } else {
                    // we didn't get the lock, so let's see what happened by re-checking
                    if (!materializeExistingLocus(listener, locus)) {
                        log.warning("Couldn't get lock and couldn't find locus on other node!",
                            "locus", locus, "nodeName", nodeName);
                        listener.requestFailed("Whacked Out Node");
                    }
                }
            }
    
            protected void hostLocus () {
                try {
                    LocusRegistry.this.hostLocus(locus, new ResultListener<HostedLocus>() {
                        @Override public void requestCompleted (HostedLocus result) {
                            OrthNodeObject node = ((OrthNodeObject)_peerMan.getNodeObject());
                            node.addToSet(_dsetName, result);
                            listener.locusMaterialized(result);
                            _peerMan.releaseLock(lock, new ResultListener.NOOP<String>());
                        }
    
                        @Override public void requestFailed (Exception cause) {
                            log.warning("Couldn't host locus! Fffffffffff...", "locus", locus,
                                cause);
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
                log.warning("Couldn't get room locus lock!", "locus", locus, cause);
            }
        });
    }

    /**
     * Attempts to materialize a locus without performing only a lookup on the locus within the
     * peer system (no actual resolution of the locus content).
     */
    protected boolean materializeExistingLocus (LocusMaterializationListener listener, Locus locus)
    {
        HostedLocus hosted = _peerMan.findHostedLocus(_dsetName, locus);
        if (hosted != null) {
            listener.locusMaterialized(hosted);
            return true;
        }
        return false;
    }

    /**
     * Gets the name of the peer system lock to use in performing locus resolution.
     */
    protected String getLockName ()
    {
        return _dsetName + "Lock";
    }

    /**
     * Hosts the locus on the local server and reports the result back to the given listener. The
     * calling environment will take care of releasing peer locks.
     */
    protected abstract void hostLocus (Locus locus, ResultListener<HostedLocus> rl);

    /** The name of the det governing our hosted locus instances in the OrthNodeObject. */
    protected String _dsetName;

    // dependencies
    @Inject protected OrthPeerManager _peerMan;
}
