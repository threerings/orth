//
// $Id: OrthSceneRegistry.java 19814 2011-01-10 15:11:24Z zell $

package com.threerings.orth.room.server;

import com.threerings.presents.data.ClientObject;
import com.threerings.presents.data.InvocationCodes;
import com.threerings.presents.server.InvocationException;
import com.threerings.presents.server.InvocationManager;
import com.threerings.whirled.client.SceneService.SceneMoveListener;
import com.threerings.whirled.data.SceneCodes;
import com.threerings.whirled.server.SceneManager;
import com.threerings.whirled.spot.server.SpotSceneRegistry;

import com.threerings.orth.server.OrthDeploymentConfig;
import com.threerings.orth.world.client.WorldService.PlaceResolutionListener;
import com.threerings.orth.world.data.OrthPlace;
import com.threerings.orth.world.data.PlaceKey;
import com.threerings.orth.world.server.WorldManager;
import com.threerings.orth.peer.data.HostedPlace;
import com.threerings.orth.peer.server.OrthPeerManager;
import com.threerings.orth.room.data.ActorObject;
import com.threerings.orth.room.data.OrthLocation;
import com.threerings.orth.room.data.OrthRoomCodes;
import com.threerings.orth.room.data.OrthSceneMarshaller;
import com.threerings.orth.room.data.RoomKey;
import com.google.inject.Inject;
import com.google.inject.Injector;
import com.google.inject.Singleton;

/**
 * Handles some custom Whirled scene traversal business.
 */
@Singleton
public class OrthSceneRegistry extends SpotSceneRegistry
    implements OrthSceneProvider, WorldManager.PlaceFactory
{
    @Inject public OrthSceneRegistry (InvocationManager invmgr, WorldManager worldMan)
    {
        super(invmgr);
        invmgr.registerProvider(this, OrthSceneMarshaller.class, SceneCodes.WHIRLED_GROUP);
        worldMan.registerFactory(OrthRoomCodes.ROOM_PLACE_TYPE, this);
    }

    // from interface OrthSceneProvider
    public void moveTo (ClientObject caller, int sceneId, int version, int portalId,
        OrthLocation destLoc, SceneMoveListener listener)
        throws InvocationException
    {
        final ActorObject mover = (ActorObject) caller;

        // ORTH TODO: this is where the follow code was; that belongs in WorldManager now

        resolveScene(sceneId, new OrthSceneMoveHandler(
                _locman, mover, version, portalId, destLoc, listener));
    }

    // from interface WorldManager.PlaceFactory
    public void resolveLocalPlace (
        final String ourNode, PlaceKey key, final PlaceResolutionListener listener)
    {
        resolveScene(((RoomKey) key).sceneId, new ResolutionListener() {
            public void sceneWasResolved (SceneManager scmgr) {
                listener.placeLocated(ourNode, getHost(), getPorts());
            }
            public void sceneFailedToResolve (int sceneId, Exception reason) {
                listener.requestFailed(InvocationCodes.INTERNAL_ERROR);
            }
        });
    }


    public OrthPlace toPlace (String nodeName, HostedPlace hostedPlace)
    {
        // ORTH TODO
        return null;
    }

    public String getHost ()
    {
        return _depConf.getRoomHost();
    }

    public int[] getPorts ()
    {
        return _depConf.getRoomPorts();
    }

    // our dependencies
    @Inject protected Injector _injector;
    @Inject protected OrthPeerManager _peerMan;
    @Inject protected OrthDeploymentConfig _depConf;
}
