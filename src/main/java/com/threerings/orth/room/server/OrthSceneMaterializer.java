//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.room.server;

import com.google.inject.Inject;
import com.google.inject.Injector;
import com.google.inject.Singleton;

import com.samskivert.util.ResultListener;

import com.threerings.util.Resulting;

import com.threerings.presents.data.ClientObject;
import com.threerings.presents.server.InvocationException;
import com.threerings.presents.server.InvocationManager;

import com.threerings.crowd.server.LocationManager;

import com.threerings.whirled.client.SceneService.SceneMoveListener;
import com.threerings.whirled.data.SceneCodes;
import com.threerings.whirled.server.SceneManager;
import com.threerings.whirled.server.SceneRegistry.ResolutionListener;
import com.threerings.whirled.spot.server.SpotSceneRegistry;

import com.threerings.orth.data.AuthName;
import com.threerings.orth.locus.client.LocusService.LocusMaterializationListener;
import com.threerings.orth.locus.data.HostedLocus;
import com.threerings.orth.locus.server.LocusMaterializer;
import com.threerings.orth.nodelet.data.HostedNodelet;
import com.threerings.orth.nodelet.data.Nodelet;
import com.threerings.orth.nodelet.server.DSetNodeletHoster;
import com.threerings.orth.nodelet.server.HostNodeletRequest;
import com.threerings.orth.peer.data.OrthNodeObject;
import com.threerings.orth.peer.server.OrthPeerManager;
import com.threerings.orth.room.data.ActorObject;
import com.threerings.orth.room.data.OrthLocation;
import com.threerings.orth.room.data.OrthSceneMarshaller;
import com.threerings.orth.room.data.RoomLocus;
import com.threerings.orth.server.OrthDeploymentConfig;

/**
 * Handles some custom Orth scene traversal business.
 */
@Singleton
public class OrthSceneMaterializer
    implements OrthSceneProvider, LocusMaterializer<RoomLocus>
{
    @Inject public OrthSceneMaterializer (InvocationManager invmgr, Injector injector)
    {
        invmgr.registerProvider(this, OrthSceneMarshaller.class, SceneCodes.WHIRLED_GROUP);

        // a little inline hoster that just uses the scene registry once the job of hosting falls
        // to the local peer
        injector.injectMembers(_hoster = createHoster());
    }

    // -- BITS THAT RUN ON THE VAULT SERVER
    @Override
    public void materializeLocus (ClientObject caller, final RoomLocus locus,
        final LocusMaterializationListener listener)
    {
        // we re-route materialization via NodeletHoster so that we first get the lock and publish
        // the fact that we are hosting this scene
        _hoster.resolveHosting(caller, locus, new Resulting<HostedNodelet> (listener) {
            @Override public void requestCompleted (HostedNodelet result) {
                listener.locusMaterialized(new HostedLocus(locus, result.host, result.ports));
            }
        });
    }

    protected static class OrthNodeletHoster extends DSetNodeletHoster
    {
        public OrthNodeletHoster (String dsetName, Class<? extends Nodelet> nclass)
        {
            super(dsetName, nclass);
        }

        @Override
        protected HostNodeletRequest createHostingRequest (AuthName caller, Nodelet nodelet)
        {
            return new OrthSceneHoster(caller, OrthNodeObject.HOSTED_ROOMS, nodelet);
        }
    }


    // -- BITS THAT RUN ON THE ROOM SERVER

    @Override
    public void moveTo (ClientObject caller, int sceneId, int version, int portalId,
        OrthLocation destLoc, SceneMoveListener listener)
        throws InvocationException
    {
        final ActorObject mover = (ActorObject) caller;

        // NOTE: this should only ever be called as the last stage of a locus-routed move, where
        // we know we've already resolved the scene on this server in OrthSceneHoster
        _sceneReg.resolveScene(sceneId, new OrthSceneMoveHandler(
                _locman, mover, version, portalId, destLoc, listener));
    }

    protected DSetNodeletHoster createHoster ()
    {
        return new OrthNodeletHoster(OrthNodeObject.HOSTED_ROOMS, RoomLocus.class);
    }

    protected static class OrthSceneHoster extends HostNodeletRequest
    {
        public OrthSceneHoster (AuthName user, String dsetName, Nodelet nodelet)
        {
            super(user, dsetName, nodelet);
        }

        @Override protected void hostLocally (AuthName caller, Nodelet nodelet,
            final ResultListener<HostedNodelet> listener) {
            final HostedNodelet room = new HostedNodelet(
                nodelet, _depConf.getRoomHost(), _depConf.getRoomPorts());
            _sceneReg.resolveScene(((RoomLocus) nodelet).sceneId, new ResolutionListener() {
                @Override public void sceneWasResolved (SceneManager scmgr) {
                    listener.requestCompleted(room);
                }
                @Override public void sceneFailedToResolve (int sceneId, Exception reason) {
                    listener.requestFailed(reason);
                }
            });
        }

        @Inject protected transient OrthDeploymentConfig _depConf;
        @Inject protected transient SpotSceneRegistry _sceneReg;
    }

    @Override
    public String toString ()
    {
        return getClass().getSimpleName();
    }

    protected DSetNodeletHoster _hoster;

    // our dependencies
    @Inject protected Injector _injector;
    @Inject protected OrthPeerManager _peerMan;
    @Inject protected LocationManager _locman;
    @Inject protected SpotSceneRegistry _sceneReg;
}
