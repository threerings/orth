//
// Who - Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.room.server;

import com.google.common.base.Preconditions;
import com.google.inject.Inject;
import com.google.inject.Injector;
import com.google.inject.Singleton;

import com.samskivert.util.ResultListener;

import com.threerings.presents.data.ClientObject;
import com.threerings.presents.server.InvocationException;
import com.threerings.presents.server.InvocationManager;

import com.threerings.whirled.client.SceneService.SceneMoveListener;
import com.threerings.whirled.server.SceneManager;
import com.threerings.whirled.server.SceneRegistry.ResolutionListener;

import com.threerings.orth.aether.data.AetherClientObject;
import com.threerings.orth.data.AuthName;
import com.threerings.orth.instance.data.Instance;
import com.threerings.orth.instance.data.InstanceInfo;
import com.threerings.orth.instance.server.InstanceRegistry;
import com.threerings.orth.locus.client.LocusService.LocusMaterializationListener;
import com.threerings.orth.nodelet.data.HostedNodelet;
import com.threerings.orth.nodelet.data.Nodelet;
import com.threerings.orth.nodelet.server.DSetNodeletHoster;
import com.threerings.orth.nodelet.server.HostNodeletRequest;
import com.threerings.orth.peer.data.OrthNodeObject;
import com.threerings.orth.room.data.InstancedRoomLocus;
import com.threerings.orth.room.data.RoomLocus;
import com.threerings.orth.room.data.SocializerObject;

import static com.threerings.orth.Log.log;

/**
 * Customizes {@link OrthSceneMaterializer} for instanced operation.
 */

@Singleton
public class InstancedSceneMaterializer extends OrthSceneMaterializer
{
    @Inject public InstancedSceneMaterializer (InvocationManager invmgr, Injector injector)
    {
        super(invmgr, injector);
    }

    // -- BITS THAT RUN ON THE VAULT SERVER
    @Override
    public void materializeLocus (ClientObject caller, RoomLocus locus,
        LocusMaterializationListener listener)
    {
        String instanceId = null;
        if (locus instanceof InstancedRoomLocus) {
            instanceId = ((InstancedRoomLocus) locus).instanceId;
        } else {
            log.warning("Got a non-instanced RoomLocus", "caller", caller.who(), "locus", locus);
        }

        // if we're not in an instance yet, pick one (this will get much more involved shortly)
        if (instanceId == null) {
            locus = new InstancedRoomLocus(
                pickInstanceForPlayer((AetherClientObject) caller, locus.sceneId),
                locus.sceneId, locus.loc);
        }

        super.materializeLocus(caller, locus, listener);
    }

    protected String pickInstanceForPlayer (AetherClientObject player, int sceneId)
    {
        return "public";
    }

    @Override protected DSetNodeletHoster createHoster ()
    {
        return new InstancedNodeletHoster();
    }

    protected static class InstancedNodeletHoster extends OrthNodeletHoster
    {
        public InstancedNodeletHoster ()
        {
            super(OrthNodeObject.HOSTED_ROOMS, InstancedRoomLocus.class);
        }

        @Override protected HostNodeletRequest createHostingRequest (
            AuthName caller, Nodelet nodelet)
        {
            return new InstancedSceneHoster(caller, OrthNodeObject.HOSTED_ROOMS, nodelet);
        }

        // TODO: This can be significantly cleaned up when we have OrthNodeObject.instances
        @Override protected String determineHostingPeer (Nodelet toHost)
        {
            String instanceId = ((InstancedRoomLocus) toHost).instanceId;

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
        SocializerObject body = (SocializerObject) caller;
        String instanceId = ((InstancedRoomLocus) locus).instanceId;
        Instance instance = Preconditions.checkNotNull(_instreg.getInstance(instanceId),
            "No instance named '%s' registered.", instanceId);

        // if we're not in this instance yet, we want to be
        if (Instance.getFor(body) != instance) {
            instance.addPlayer(body);
        }

        // now go there -- the scene is really resolved already, by the SceneHoster below.
        instance.resolveScene(locus.sceneId,
            new OrthSceneMoveHandler(_locman, body, version, portalId, locus.loc, listener));
    }

    protected static class InstancedSceneHoster extends OrthSceneHoster
    {
        public InstancedSceneHoster (AuthName user, String dsetName, Nodelet nodelet)
        {
            super(user, dsetName, nodelet);
        }

        @Override protected void hostLocally (
            AuthName caller, Nodelet nodelet, final ResultListener<HostedNodelet> listener)
        {
            String instanceId = ((InstancedRoomLocus) nodelet).instanceId;
            Instance instance = _instreg.getInstance(instanceId);
            if (instance == null) {
                // TODO: use an Instance subclass here
                instance = new Instance(instanceId);
                _injector.injectMembers(instance);
                _instreg.registerInstance(instance);
            }

            final HostedNodelet room = new HostedNodelet(
                nodelet, _depConf.getRoomHost(), _depConf.getRoomPorts());
            instance.resolveScene(((RoomLocus) nodelet).sceneId, new ResolutionListener() {
                @Override public void sceneWasResolved (SceneManager scmgr) {
                    listener.requestCompleted(room);
                }
                @Override public void sceneFailedToResolve (int sceneId, Exception reason) {
                    listener.requestFailed(reason);
                }
            });
        }

        @Inject protected transient Injector _injector;
        @Inject protected transient InstanceRegistry _instreg;
    }

    @Inject protected InstanceRegistry _instreg;
}
