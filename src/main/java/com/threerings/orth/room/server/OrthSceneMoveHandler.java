/**
 *
 */
package com.threerings.orth.room.server;

import com.google.inject.Inject;
import com.threerings.crowd.data.BodyObject;
import com.threerings.crowd.server.LocationManager;
import com.threerings.orth.room.data.OrthLocation;
import com.threerings.orth.room.data.OrthPortal;
import com.threerings.orth.room.data.OrthScene;
import com.threerings.orth.room.data.PetObject;
import com.threerings.orth.room.data.SocializerObject;
import com.threerings.presents.server.InvocationException;
import com.threerings.whirled.client.SceneMoveAdapter;
import com.threerings.whirled.client.SceneService.SceneMoveListener;
import com.threerings.whirled.server.SceneManager;
import com.threerings.whirled.server.SceneMoveHandler;

import static com.threerings.orth.Log.log;

/**
 * Handle all the complexities that happen on Whirled when you transition from one scene
 * to another, including the theme-boundary-crossing checks and manipulations.
 */
public class OrthSceneMoveHandler extends SceneMoveHandler
{
    public OrthSceneMoveHandler (LocationManager locman, BodyObject mover,
        int sceneVer, int portalId, OrthLocation destLoc, SceneMoveListener listener)
    {
        super(locman, mover, sceneVer, listener);
        _portalId = portalId;
        _destLoc = destLoc;
        _mover = mover;
        _memobj = (mover instanceof SocializerObject) ? (SocializerObject) mover : null;
    }

    @Override
	protected void effectSceneMove (SceneManager scmgr)
        throws InvocationException
    {
        final OrthScene scene = (OrthScene) scmgr.getScene();
        final OrthRoomManager destmgr = (OrthRoomManager)scmgr;

        // if we're not going to be let into the room, let our listener know now
        String accessMsg = scmgr.ratifyBodyEntry(_mover);
        if (accessMsg != null) {
            _listener.requestFailed(accessMsg);
            return;
        }

        // ORTH TODO -- A lot later
        // _petobj = (_memobj != null) ? _petMan.getPetObject(_memobj.walkingId) : null;

        // create a fake "from" portal that contains our destination location
        OrthPortal from = new OrthPortal();
        from.targetPortalId = (short)-1;
        from.dest = _destLoc;

        // let the destination room manager know that we're coming in "from" that portal
        destmgr.mapEnteringBody(_mover, from);

        try {
            OrthSceneMoveHandler.super.effectSceneMove(destmgr);

        } catch (InvocationException ie) {
            // if anything goes haywire, clear out our entering status
            destmgr.clearEnteringBody(_mover);
            log.warning("Scene move failed", "mover", _mover.who(),
                "sceneId", scene.getId(), ie);
            _listener.requestFailed(ie.getMessage());
            return;
        }

        if (_petobj != null) {
            try {
                _screg.moveTo(_petobj, scene.getId(), Integer.MAX_VALUE, _portalId, _destLoc,
                    new SceneMoveAdapter());

            } catch (InvocationException ie) {
                log.warning("Pet follow failed", "memberId", _memobj.getPlayerId(),
                    "sceneId", scene.getId(), ie);
            }
        }
    }

    protected int _portalId;
    protected OrthLocation _destLoc;
    protected SocializerObject _memobj;
    protected BodyObject _mover;
    protected PetObject _petobj;

    @Inject protected OrthSceneRegistry _screg;
    // ORTH TODO -- A lot later
    // @Inject protected PetManager _petMan;
}
