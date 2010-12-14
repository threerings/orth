//
// $Id: MsoySceneDirector.as 18370 2009-10-13 22:43:55Z jamie $

package com.threerings.orth.room.client {

import com.threerings.io.TypedArray;
import com.threerings.orth.data.OrthCodes;
import com.threerings.orth.data.OrthName;
import com.threerings.orth.room.client.OrthSceneFactory;
import com.threerings.orth.room.data.OrthPortal;
import com.threerings.orth.room.data.OrthScene;
import com.threerings.orth.room.data.OrthRoomMarshaller;
import com.threerings.orth.room.data.OrthRoomCodes;
import com.threerings.orth.room.data.OrthSceneMarshaller;
import com.threerings.orth.world.client.WorldContext;
import com.threerings.orth.world.client.WorldController;
import com.threerings.presents.client.Client;
import com.threerings.presents.client.ClientEvent;
import com.threerings.presents.dobj.MessageAdapter;
import com.threerings.presents.dobj.MessageEvent;
import com.threerings.util.Log;
import com.threerings.util.ResultListener;

import com.threerings.crowd.client.LocationDirector;
import com.threerings.crowd.data.PlaceConfig;

import com.threerings.whirled.client.PendingData;
import com.threerings.whirled.client.SceneDirector;
import com.threerings.whirled.client.SceneService_SceneMoveListener;
import com.threerings.whirled.client.persist.SceneRepository;

/**
 * Handles custom scene traversal and extra bits for Whirled.
 */
public class OrthSceneDirector extends SceneDirector
    implements SceneService_SceneMoveListener
{
    private const log :Log = Log.getLog(this);

    // statically reference classes we require
    OrthSceneMarshaller;

    public function OrthSceneDirector (
        ctx :WorldContext, locDir :LocationDirector, repo :SceneRepository)
    {
        super(ctx, locDir, repo, new OrthSceneFactory());
        _worldctx = ctx;
    }

    /**
     * Traverses the specified portal using the OrthSceneService which handles switching between
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

        // prepare to move to this scene (sets up pending data)
        if (!prepareMoveTo(dest.targetSceneId, null)) {
            log.info("Portal traversal vetoed", "portalId", portalId);
            return false;
        }

        // note our departing portal id and target location in the destination scene
        _departingPortalId = portalId;
        (_pendingData as OrthPendingData).destLoc = dest.dest;

        // now that everything is noted (in case we have to switch servers) ask to move
        sendMoveRequest();
        return true;
    }

    // from SceneDirector
    override public function moveSucceeded (placeId :int, config :PlaceConfig) :void
    {
        var data :OrthPendingData = _pendingData as OrthPendingData;
        if (data != null && data.message != null) {
            _worldctx.displayFeedback(OrthCodes.GENERAL_MSGS, data.message);
        }

        super.moveSucceeded(placeId, config);
    }

    // from SceneDirector
    override public function requestFailed (reason :String) :void
    {
        // remember which scene we came from, possibly on another peer
        var pendingPreviousScene :int = _pendingData != null ?
            (_pendingData as OrthPendingData).previousSceneId : -1;

        _departingPortalId = -1;
        super.requestFailed(reason);

        _worldctx.displayFeedback(OrthCodes.GENERAL_MSGS, reason);

        // otherwise try to deal with the player getting bumped back from a locked scene
        if (reason == OrthRoomCodes.E_ENTRANCE_DENIED) {
            bounceBack(_sceneId, pendingPreviousScene, reason);
        }
    }

    // from SceneDirector
    override protected function createPendingData () :PendingData
    {
        return new OrthPendingData();
    }

    // from SceneDirector
    override public function prepareMoveTo (sceneId :int, rl :ResultListener) :Boolean
    {
        var result :Boolean = super.prepareMoveTo(sceneId, rl);
        if (result) {
            // super creates a pending request - fill it in with extra data
            var data :OrthPendingData = _pendingData as OrthPendingData;
            data.previousSceneId = _sceneId;
            data.message = _postMoveMessage;
            _postMoveMessage = null;
        }
        return result;
    }

    // from SceneDirector
    override protected function sendMoveRequest () :void
    {
        var data :OrthPendingData = _pendingData as OrthPendingData;

        // special code to handle moving to scene 0 (leaving all scenes)
        if (data.sceneId == 0) {
            _previousSceneId = _sceneId;
            _pendingData = null;
            _locdir.leavePlace();
            _sceneId = 0; // not -1
            return;
        }

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
        log.info("Issuing moveTo(" + data.previousSceneId + "->" + data.sceneId + ", " +
                 sceneVers + ", " + _departingPortalId + ", " + data.destLoc + ").");
        _mssvc.moveTo(data.sceneId, sceneVers, _departingPortalId, data.destLoc, this);
    }

    // documentation inherited
    override public function clientDidLogon (event :ClientEvent) :void
    {
        super.clientDidLogon(event);

        // add a listener that will respond to follow notifications
        _ctx.getClient().getClientObject().addListener(_followListener);
    }

    // documentation inherited
    override public function clientDidLogoff (event :ClientEvent) :void
    {
        super.clientDidLogoff(event);

        _departingPortalId = -1;
        // _followListener implicitly goes away with our client object
    }

    // from SceneDirector
    override protected function fetchServices (client :Client) :void
    {
        super.fetchServices(client);
        // get a handle on our special scene service
        _mssvc = (client.requireService(OrthSceneService) as OrthSceneService);
    }

    /**
     * Do whatever cleanup is appropriate after we failed to enter a locked room. Returns true
     * if the problem was handled, false for subclasses to take over.
     */
    protected function bounceBack (localSceneId :int, remoteSceneId :int, reason :String) :Boolean
    {
        var ctrl :WorldController = _worldctx.getWorldController();

        // if we came here from a scene on another peer, let's go back there
        if (remoteSceneId != -1) {
            log.info("Returning to remote scene", "sceneId", remoteSceneId);
            _postMoveMessage = reason; // remember the error message
            ctrl.handleGoScene(remoteSceneId);
            return true;
        }

        // The Orth layer doesn't know how to deal with this; subclasses need to take over here
        return false;
    }

    protected function memberMessageReceived (event :MessageEvent) :void
    {
        if (event.getName() == OrthRoomCodes.FOLLOWEE_MOVED) {
            var sceneId :int = int(event.getArgs()[0]);
            log.info("Following " + _worldctx.getPlayerObject().following + " to " + sceneId + ".");
            moveTo(sceneId);
        }
    }

    protected var _worldctx :WorldContext;

    protected var _mssvc :OrthSceneService;
    protected var _postMoveMessage :String;
    protected var _departingPortalId :int = -1;
    protected var _followListener :MessageAdapter = new MessageAdapter(memberMessageReceived);
}
}
