//
// $Id$

package com.threerings.orth.room.server;

import com.google.inject.Inject;
import com.google.inject.Injector;
import com.google.inject.Singleton;

import com.samskivert.util.ResultListener;

import com.threerings.orth.locus.data.Locus;
import com.threerings.orth.locus.server.LocusMaterializer;
import com.threerings.orth.nodelet.data.HostedNodelet;
import com.threerings.orth.peer.data.OrthNodeObject;
import com.threerings.orth.peer.server.OrthPeerManager;
import com.threerings.orth.room.data.ActorObject;
import com.threerings.orth.room.data.OrthLocation;
import com.threerings.orth.room.data.OrthSceneMarshaller;
import com.threerings.orth.server.OrthDeploymentConfig;
import com.threerings.presents.data.ClientObject;
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
    @Inject public OrthSceneRegistry (InvocationManager invmgr, Injector injector)
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
    public void materializeLocus (ClientObject caller, final Locus locus,
            final ResultListener<HostedNodelet> rl)
    {
        resolveScene(locus.getId(), new ResolutionListener() {
            @Override public void sceneWasResolved (SceneManager scmgr) {
                rl.requestCompleted(new HostedNodelet(locus, getHost(), getPorts()));
            }
            @Override public void sceneFailedToResolve (int sceneId, Exception reason) {
                rl.requestFailed(reason);
            }
        });
    }

    @Override
    public String getDSetName ()
    {
        return OrthNodeObject.HOSTED_ROOMS;
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
