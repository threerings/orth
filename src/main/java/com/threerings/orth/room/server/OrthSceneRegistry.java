//
// $Id: OrthSceneRegistry.java 19814 2011-01-10 15:11:24Z zell $

package com.threerings.orth.room.server;

import static com.threerings.orth.Log.log;

import com.google.inject.Inject;
import com.google.inject.Injector;
import com.google.inject.Singleton;

import com.samskivert.util.ResultListener;

import com.threerings.orth.locus.client.LocusService.LocusMaterializationListener;
import com.threerings.orth.locus.data.HostedLocus;
import com.threerings.orth.locus.data.Locus;
import com.threerings.orth.locus.server.LocusMaterializer;
import com.threerings.orth.peer.data.OrthNodeObject;
import com.threerings.orth.peer.server.OrthPeerManager;
import com.threerings.orth.room.data.ActorObject;
import com.threerings.orth.room.data.HostedRoom;
import com.threerings.orth.room.data.OrthLocation;
import com.threerings.orth.room.data.OrthSceneMarshaller;
import com.threerings.orth.room.data.RoomLocus;
import com.threerings.orth.server.OrthDeploymentConfig;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.peer.data.NodeObject;
import com.threerings.presents.peer.data.NodeObject.Lock;
import com.threerings.presents.server.InvocationException;
import com.threerings.presents.server.InvocationManager;
import com.threerings.whirled.client.SceneService.SceneMoveListener;
import com.threerings.whirled.data.SceneCodes;
import com.threerings.whirled.server.SceneManager;
import com.threerings.whirled.spot.server.SpotSceneRegistry;

/**
 * Handles some custom Whirled scene traversal business.
 */
@Singleton
public class OrthSceneRegistry extends SpotSceneRegistry
    implements OrthSceneProvider, LocusMaterializer
{
    @Inject public OrthSceneRegistry (InvocationManager invmgr)
    {
        super(invmgr);
        invmgr.registerProvider(this, OrthSceneMarshaller.class, SceneCodes.WHIRLED_GROUP);
    }

    // from interface OrthSceneProvider
    @Override
    public void moveTo (ClientObject caller, int sceneId, int version, int portalId,
        OrthLocation destLoc, SceneMoveListener listener)
        throws InvocationException
    {
        final ActorObject mover = (ActorObject) caller;

        // ORTH TODO: this is where the follow code was; that belongs in WorldManager now

        // ORTH TODO: Should this be a locus materialization?
        resolveScene(sceneId, new OrthSceneMoveHandler(
                _locman, mover, version, portalId, destLoc, listener));
    }

    @Override
    public void materializeLocus (ClientObject caller, Locus locus,
        final LocusMaterializationListener listener)
    {
        final RoomLocus rlocus = (RoomLocus)locus;
        if (materializeExistingRoom(listener, rlocus)) {
             return;
        }

        // ORTH TODO: At this point we know the locus needs to be hosted. For now, we will
        // resolve it locally, but what should really happen here is that the nodes should
        // all be queried to see which room peer is the least loaded and the request should
        // be punted to there.

        final NodeObject.Lock lock = new NodeObject.Lock("RoomLocus", rlocus);
        _peerMan.acquireLock(lock, new LocusLockListener(listener, lock, rlocus));
    }

    protected class LocusLockListener
        implements ResultListener<String>
    {
        protected LocusLockListener (LocusMaterializationListener listener, Lock lock,
                RoomLocus locus) {
            _listener = listener;
            _lock = lock;
            _locus = locus;
        }

        @Override public void requestCompleted (String nodeName) {
            if (_peerMan.getNodeObject().nodeName.equals(nodeName)) {
                log.info("Got RoomLocus lock", "locus", _locus);
                hostLocus();

            } else {
                // we didn't get the lock, so let's see what happened by re-checking
                if (!materializeExistingRoom(_listener, _locus)) {
                    log.warning("Couldn't get lock and couldn't find created locus on other node!",
                        "locus", _locus, "nodeName", nodeName);
                    _listener.requestFailed("Whacked Out Node");
                }
            }

        }

        protected void hostLocus ()
        {
            try {
                resolveScene(_locus.sceneId, new ResolutionListener() {
                    @Override public void sceneWasResolved (SceneManager scmgr) {
                        HostedRoom hosted = new HostedRoom(_locus, getHost(), getPorts());
                        ((OrthNodeObject)_peerMan.getNodeObject()).addToHostedRooms(hosted);
                        System.out.println("SENDING NEW: " + hosted);
                        _listener.locusMaterialized(hosted);
                        _peerMan.releaseLock(_lock, new ResultListener.NOOP<String>());
                    }

                    @Override public void sceneFailedToResolve (int sceneId, Exception reason) {
                        log.warning("Couldn't resolve roomlocus scene! Fffffffffff...", "sceneId", sceneId,
                            reason);
                        _peerMan.releaseLock(_lock, new ResultListener.NOOP<String>());
                    }
                });

            } catch (RuntimeException re) {
                _peerMan.releaseLock(_lock, new ResultListener.NOOP<String>());
                throw re;
            }
        }

        @Override
        public void requestFailed (Exception cause) {
            log.warning("Couldn't get room locus lock!", "locus", _locus, cause);
        }

        protected final LocusMaterializationListener _listener;
        protected final Lock _lock;
        protected final RoomLocus _locus;
    }

    protected boolean materializeExistingRoom (LocusMaterializationListener listener,
        RoomLocus locus)
    {
        HostedLocus hosted = _peerMan.findHostedRoom(locus);
        if (hosted != null) {
            System.out.println("SENDING EXISTING " + hosted);
            listener.locusMaterialized(hosted);
        }
        return hosted != null;
    }
    public String getHost ()
    {
        return _depConf.getRoomHost();
    }

    public int[] getPorts ()
    {
        return _depConf.getRoomPorts();
    }

    @Override
    public String toString ()
    {
        return getClass().getSimpleName();
    }

    // our dependencies
    @Inject protected Injector _injector;
    @Inject protected OrthPeerManager _peerMan;
    @Inject protected OrthDeploymentConfig _depConf;
}
