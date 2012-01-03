//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.room.server;

import com.google.common.base.Preconditions;
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

import com.threerings.orth.aether.data.AetherClientObject;
import com.threerings.orth.data.AuthName;
import com.threerings.orth.instance.data.Instance;
import com.threerings.orth.instance.data.InstanceInfo;
import com.threerings.orth.instance.server.InstanceRegistry;
import com.threerings.orth.locus.client.LocusService.LocusMaterializationListener;
import com.threerings.orth.locus.data.HostedLocus;
import com.threerings.orth.locus.data.Locus;
import com.threerings.orth.locus.server.LocusMaterializer;
import com.threerings.orth.nodelet.data.HostedNodelet;
import com.threerings.orth.nodelet.data.Nodelet;
import com.threerings.orth.nodelet.server.DSetNodeletHoster;
import com.threerings.orth.nodelet.server.HostNodeletRequest;
import com.threerings.orth.peer.data.OrthNodeObject;
import com.threerings.orth.peer.server.OrthPeerManager;
import com.threerings.orth.room.data.ActorObject;
import com.threerings.orth.room.data.OrthSceneMarshaller;
import com.threerings.orth.room.data.RoomLocus;
import com.threerings.orth.server.OrthDeploymentConfig;

import static com.threerings.orth.Log.log;

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
    public void materializeLocus (ClientObject caller, RoomLocus locus,
        final LocusMaterializationListener listener)
    {
        // if we're not in an instance yet, pick one (this will get much more involved shortly)
        if (locus.instanceId == null) {
            String newInstance = pickInstanceForPlayer((AetherClientObject) caller, locus.sceneId);
            locus = new RoomLocus(locus.sceneId, newInstance, locus.loc);
        }

        final Locus fLoc = locus;
        // we re-route materialization via NodeletHoster so that we first get the lock and publish
        // the fact that we are hosting this scene
        _hoster.resolveHosting(caller, locus, new Resulting<HostedNodelet>(listener) {
            @Override public void requestCompleted (HostedNodelet result) {
                listener.locusMaterialized(new HostedLocus(fLoc, result.host, result.ports));
            }
        });
    }

    protected String pickInstanceForPlayer (AetherClientObject player, int sceneId)
    {
        return "public";
    }

    protected DSetNodeletHoster createHoster ()
    {
        return new OrthNodeletHoster(OrthNodeObject.HOSTED_ROOMS, RoomLocus.class);
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

        @Override protected String determineHostingPeer (Nodelet toHost)
        {
            String instanceId = ((RoomLocus) toHost).instanceId;

            // iterate over all hosted rooms in all nodes
            for (OrthNodeObject obj : _peerMan.getOrthNodeObjects()) {
                if (obj.instances.containsKey(InstanceInfo.makeKey(instanceId))) {
                    log.debug("Hosting scene on existing instance peer",
                        "toHost", toHost, "peer", obj.nodeName);
                    return obj.nodeName;
                }
            }

            // if not, this is an unhosted instance: fall back on load-balancing
            String peer = super.determineHostingPeer(toHost);
            log.debug("Hosting entirely new instance", "toHost", toHost, "peer", peer);
            return peer;
        }
    }


    // -- BITS THAT RUN ON THE ROOM SERVER

    @Override
    public void moveTo (ClientObject caller, RoomLocus locus, int version, int portalId,
        SceneMoveListener listener) throws InvocationException
    {
        final ActorObject body = (ActorObject) caller;
        Instance instance = Preconditions.checkNotNull(_instreg.getInstance(locus.instanceId),
            "No instance named '%s' registered.", locus.instanceId);

        // if we're not in this instance yet, we want to be
        if (Instance.getFor(body) != instance) {
            instance.addPlayer(body);
        }

        // now go there -- the scene is really resolved already, by the SceneHoster below.
        instance.resolveScene(locus.sceneId,
            new OrthSceneMoveHandler(_locman, body, version, portalId, locus.loc, listener));
    }

    protected static class OrthSceneHoster extends HostNodeletRequest
    {
        public OrthSceneHoster (AuthName user, String dsetName, Nodelet nodelet)
        {
            super(user, dsetName, nodelet);
        }

        @Override protected void hostLocally (AuthName caller, Nodelet nodelet,
            final ResultListener<HostedNodelet> listener) {
            final RoomLocus locus = (RoomLocus) nodelet;

            Instance instance = _instreg.getInstance(locus.instanceId);
            if (instance == null) {
                instance = createInstance(locus);
                registerInstance(instance);
            }

            instance.resolveScene(locus.sceneId, new ResolutionListener() {
                @Override public void sceneWasResolved (SceneManager scmgr) {
                    listener.requestCompleted(new HostedNodelet(
                        locus, _depConf.getRoomHost(), _depConf.getRoomPorts()));
                }
                @Override public void sceneFailedToResolve (int sceneId, Exception reason) {
                    listener.requestFailed(reason);
                }
            });
        }

        protected void registerInstance (Instance instance)
        {
            _instreg.registerInstance(instance);

            // NOTE: This does no locking nor coordination with other peers. It does not e.g.
            // try to ensure that an instance is only hosted on one peer (because that is not
            // always what's wanted).
            InstanceInfo info = instance.toInfo();
            if (_peerman.getOrthNodeObject().instances.contains(info)) {
                log.warning("InstanceInfo already registered on OrthNodeObject",
                    "instance", instance.getInstanceId());
            } else {
                _peerman.getOrthNodeObject().addToInstances(info);
            }
        }

        protected Instance createInstance (RoomLocus locus)
        {
            Instance instance = new Instance(locus.instanceId);
            _injector.injectMembers(instance);
            return instance;
        }

        @Inject protected transient OrthDeploymentConfig _depConf;
        @Inject protected transient Injector _injector;
        @Inject protected transient InstanceRegistry _instreg;
        @Inject protected transient OrthPeerManager _peerman;
    }

    @Override
    public String toString ()
    {
        return getClass().getSimpleName();
    }

    protected DSetNodeletHoster _hoster;

    // our dependencies
    @Inject protected Injector _injector;
    @Inject protected InstanceRegistry _instreg;
    @Inject protected LocationManager _locman;
    @Inject protected OrthPeerManager _peerMan;
}
