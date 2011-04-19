//
// $Id$

package com.threerings.orth.room.server;

import com.google.inject.Inject;
import com.google.inject.Injector;
import com.google.inject.Singleton;

import com.samskivert.util.ResultListener;

import com.threerings.orth.data.AuthName;
import com.threerings.orth.locus.client.LocusService.LocusMaterializationListener;
import com.threerings.orth.locus.data.Locus;
import com.threerings.orth.locus.server.LocusMaterializer;
import com.threerings.orth.nodelet.data.HostedNodelet;
import com.threerings.orth.nodelet.data.Nodelet;
import com.threerings.orth.nodelet.server.NodeletHoster;
import com.threerings.orth.peer.data.OrthNodeObject;
import com.threerings.orth.peer.server.OrthPeerManager;
import com.threerings.orth.room.data.ActorObject;
import com.threerings.orth.room.data.OrthLocation;
import com.threerings.orth.room.data.OrthSceneMarshaller;
import com.threerings.orth.server.OrthDeploymentConfig;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.server.InvocationException;
import com.threerings.presents.server.InvocationManager;
import com.threerings.util.Resulting;
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
    @Inject public OrthSceneRegistry (InvocationManager invmgr, Injector injector)
    {
        super(invmgr);
        invmgr.registerProvider(this, OrthSceneMarshaller.class, SceneCodes.WHIRLED_GROUP);

        // a little inline hoster that just uses the scene registry when the job of hosting falls
        // to the local peer
        _hoster = new NodeletHoster(OrthNodeObject.HOSTED_ROOMS) {
            @Override protected void host (AuthName caller, Nodelet nodelet,
                    final ResultListener<HostedNodelet> listener) {
                final HostedNodelet room = new HostedNodelet(nodelet, _depConf.getRoomHost(),
                        _depConf.getRoomPorts());
                resolveScene(nodelet.getId(), new ResolutionListener() {
                    @Override public void sceneWasResolved (SceneManager scmgr) {
                        listener.requestCompleted(room);
                    }
                    @Override public void sceneFailedToResolve (int sceneId, Exception reason) {
                        listener.requestFailed(reason);
                    }
                });
            }};
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
    public void materializeLocus (ClientObject caller, final Locus locus,
        final LocusMaterializationListener listener)
    {
        // we re-route materialization via NodeletHoster so that we first get the lock and publish
        // the fact that we are hosting this scene
        _hoster.resolveHosting(caller, locus, new Resulting<HostedNodelet> (listener) {
            @Override public void requestCompleted (final HostedNodelet result) {
                listener.locusMaterialized(result);
            }
        });
    }

    @Override
    public String toString ()
    {
        return getClass().getSimpleName();
    }

    protected NodeletHoster _hoster;

    // our dependencies
    @Inject protected Injector _injector;
    @Inject protected OrthPeerManager _peerMan;
    @Inject protected OrthDeploymentConfig _depConf;
}
