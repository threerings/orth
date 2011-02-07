//
// $Id: MsoySceneDirector.as 18370 2009-10-13 22:43:55Z jamie $

package com.threerings.orth.room.client {
import flashx.funk.ioc.inject;

import com.threerings.crowd.client.LocationDirector;
import com.threerings.whirled.client.PendingData;
import com.threerings.whirled.client.SceneDirector;
import com.threerings.whirled.client.SceneService_SceneMoveListener;
import com.threerings.whirled.client.persist.SceneRepository;

import com.threerings.util.Log;

import com.threerings.presents.client.Client;
import com.threerings.presents.client.ClientEvent;
import com.threerings.presents.dobj.MessageAdapter;
import com.threerings.presents.dobj.MessageEvent;

import com.threerings.orth.client.OrthContext;
import com.threerings.orth.room.client.OrthSceneFactory;
import com.threerings.orth.room.data.OrthPortal;
import com.threerings.orth.room.data.OrthRoomCodes;
import com.threerings.orth.room.data.OrthScene;
import com.threerings.orth.room.data.OrthSceneMarshaller;
import com.threerings.orth.room.data.RoomKey;
import com.threerings.orth.world.client.WorldController;
import com.threerings.orth.world.client.WorldDirector;

/**
 * Handles custom scene traversal and extra bits for Whirled.
 */
public class OrthSceneDirector extends SceneDirector
    implements SceneService_SceneMoveListener
{
    private const log :Log = Log.getLog(this);

    // statically reference classes we require
    OrthSceneMarshaller;

    public function OrthSceneDirector ()
    {
        super(RoomContext(_octx.wctx), inject(LocationDirector),
            inject(SceneRepository), new OrthSceneFactory());
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

        _worldDir.moveTo(new RoomKey(dest.targetSceneId));
        return true;
    }

    // from SceneDirector
    override protected function sendMoveRequest () :void
    {
        var data :OrthPendingData = _pendingData as OrthPendingData;

        // special code to handle moving to scene 0 (leaving all scenes)
        if (data.sceneId == 0) {
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
        log.info("Issuing moveTo(->" + data.sceneId + ", " +
                 sceneVers + ", " + data.destLoc + ").");
        _mssvc.moveTo(data.sceneId, sceneVers, -1, data.destLoc, this);
    }

    // documentation inherited
    override public function clientDidLogon (event :ClientEvent) :void
    {
        super.clientDidLogon(event);

        // add a listener that will respond to follow notifications
        _ctx.getClient().getClientObject().addListener(_followListener);
    }

    // from SceneDirector
    override protected function fetchServices (client :Client) :void
    {
        super.fetchServices(client);
        // get a handle on our special scene service
        _mssvc = (client.requireService(OrthSceneService) as OrthSceneService);
    }

    protected function memberMessageReceived (event :MessageEvent) :void
    {
        if (event.getName() == OrthRoomCodes.FOLLOWEE_MOVED) {
            var sceneId :int = int(event.getArgs()[0]);
            log.info("Following " + _octx.getPlayerObject().following + " to " + sceneId + ".");
            moveTo(sceneId);
        }
    }

    protected const _octx :OrthContext = inject(OrthContext);
    protected const _worldCtrl :WorldController = inject(WorldController);
    protected const _worldDir :WorldDirector = inject(WorldDirector);

    protected var _mssvc :OrthSceneService;
    protected var _postMoveMessage :String;
    protected var _followListener :MessageAdapter = new MessageAdapter(memberMessageReceived);
}
}
