//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.room.client {
import flashx.funk.ioc.inject;

import com.threerings.util.Log;

import com.threerings.presents.client.Client;

import com.threerings.crowd.client.LocationDirector;
import com.threerings.crowd.data.PlaceConfig;

import com.threerings.whirled.client.PendingData;
import com.threerings.whirled.client.SceneDirector;
import com.threerings.whirled.client.SceneService_SceneMoveListener;
import com.threerings.whirled.client.persist.SceneRepository;
import com.threerings.whirled.util.SceneFactory;
import com.threerings.whirled.util.WhirledContext;

import com.threerings.orth.locus.client.LocusDirector;
import com.threerings.orth.locus.data.Locus;
import com.threerings.orth.room.data.InstancedRoomLocus;
import com.threerings.orth.room.data.OrthPortal;
import com.threerings.orth.room.data.OrthScene;
import com.threerings.orth.room.data.OrthSceneMarshaller;
import com.threerings.orth.room.data.RoomLocus;

/**
 * Handles custom scene traversal and extra bits for Orth.
 */
public class OrthSceneDirector extends SceneDirector
    implements SceneService_SceneMoveListener
{
    private const log :Log = Log.getLog(this);

    // statically reference classes we require
    OrthSceneMarshaller;

    public function OrthSceneDirector ()
    {
        super(inject(WhirledContext), inject(LocationDirector),
            inject(SceneRepository), inject(SceneFactory));
    }

    public function get locus () :RoomLocus
    {
        return _locus;
    }

    public function get instanceId () :String
    {
        return (_locus is InstancedRoomLocus) ? InstancedRoomLocus(_locus).instanceId : null;
    }

    /**
     * Traverses the specified portal using the LocusDirector, which handles switching between
     * servers and other useful business.
     *
     * @return true if we issued the request, false if it was rejected for some reason.
     */
    public function traversePortal (portalId :int) :Boolean
    {
        // look up the destination scene and location
        var scene :OrthScene = (getScene() as OrthScene);
        if (scene == null) {
            log.warning("Asked to traverse portal when we have no scene", "id", portalId);
            return false;
        }

        // find the portal they're talking about
        var dest :OrthPortal = (scene.getPortal(portalId) as OrthPortal);
        if (dest == null) {
            log.warning("Requested to traverse non-existent portal",
               "portalId", portalId, "portals", scene.getPortals());
            return false;
        }

        _locusDir.moveToLocus(this.instanceId != null ?
            new InstancedRoomLocus(this.instanceId, dest.targetSceneId, dest.dest) :
            new RoomLocus(dest.targetSceneId, dest.dest));
        return true;
    }

    /**
     * Route all movement through moveToLocalPlace.
     */
    override public function moveTo (sceneId :int) :Boolean
    {
        return moveToLocalPlace(new RoomLocus(sceneId));
    }

    public function moveToLocalPlace (locus :Locus) :Boolean
    {
        const sceneId :int = RoomLocus(locus).sceneId;
        // make sure the sceneId is valid
        if (sceneId < 0) {
            log.warning("Refusing moveToLocalPlace(): invalid sceneId", "sceneId", sceneId);
            return false;
        }

        // sanity-check the destination scene id
        if (locus.equals(_locus)) {
            log.warning("Refusing request to move to the same place", "locus", locus);
        }

        _pendingLocus = RoomLocus(locus);
        // prepare to move to this scene (sets up pending data)
        if (!prepareMoveTo(sceneId, null)) {
            return false;
        }

        // do the deed
        sendMoveRequest();
        return true;
    }


    // from SceneDirector
    override protected function createPendingData () :PendingData
    {
        return new OrthPendingData();
    }

    // from SceneDirector
    override protected function sendMoveRequest () :void
    {
        var data :OrthPendingData = OrthPendingData(_pendingData);

        // special code to handle moving to scene 0 (leaving all scenes)
        if (data.sceneId == 0) {
            _pendingData = null;
            _locdir.leavePlace();
            _sceneId = 0; // not -1
            return;
        }

        data.locus = _pendingLocus;

        // check the version of our cached copy of the scene to which we're requesting to move; if
        // we were unable to load it, assume a cached version of zero
        var sceneVers :int = 0;
        if (data.model != null) {
            sceneVers = data.model.version;
        }

        // note: _departingPortalId is only needed *before* a server switch, so we intentionally
        // allow it to get cleared out in the clientDidLogoff() call that happens as we're
        // switching from one server to another

        // issue a moveTo request
        log.info("Issuing moveTo(->" + data.locus + ", " + sceneVers + ").");
        _mssvc.moveTo(data.locus, sceneVers, -1, this);
    }

    override public function moveSucceeded (placeId :int, config :PlaceConfig) :void
    {
        _locus = _pendingLocus;
        _pendingLocus = null;

        super.moveSucceeded(placeId, config);
    }

    override protected function clearScene () :void
    {
        super.clearScene();

        _locus = null;
    }

// from SceneDirector
    override protected function fetchServices (client :Client) :void
    {
        super.fetchServices(client);
        // get a handle on our special scene service
        _mssvc = (client.requireService(OrthSceneService) as OrthSceneService);
    }

    protected var _mssvc :OrthSceneService;
    protected var _locus :RoomLocus;
    protected var _pendingLocus :RoomLocus;

    protected const _locusDir :LocusDirector = inject(LocusDirector);
}
}
