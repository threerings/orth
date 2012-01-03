//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

/**
 *
 */
package com.threerings.orth.room.server;

import com.threerings.presents.server.InvocationException;

import com.threerings.crowd.data.BodyObject;
import com.threerings.crowd.server.LocationManager;

import com.threerings.whirled.client.SceneService.SceneMoveListener;
import com.threerings.whirled.data.Scene;
import com.threerings.whirled.server.SceneManager;
import com.threerings.whirled.server.SceneMoveHandler;
import com.threerings.whirled.spot.server.SpotSceneManager;

import com.threerings.orth.room.data.OrthLocation;
import com.threerings.orth.room.data.OrthPortal;
import com.threerings.orth.room.data.PetObject;
import com.threerings.orth.room.data.SocializerObject;

import static com.threerings.orth.Log.log;

/**
 * Handle all the complexities that happen in Orth when you transition from one scene
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
        final Scene scene = scmgr.getScene();
        final SpotSceneManager destmgr = (SpotSceneManager) scmgr;

        // if we're not going to be let into the room, let our listener know now
        String accessMsg = scmgr.ratifyBodyEntry(_mover);
        if (accessMsg != null) {
            _listener.requestFailed(accessMsg);
            return;
        }

        // create a fake "from" portal that contains our destination location
        OrthPortal from = new OrthPortal();
        from.targetPortalId = (short)-1;
        from.dest = _destLoc;

        // let the destination room manager know that we're coming in "from" that portal
        destmgr.mapEnteringBody(_mover, from);

        try {
            super.effectSceneMove(destmgr);

        } catch (InvocationException ie) {
            // if anything goes haywire, clear out our entering status
            destmgr.clearEnteringBody(_mover);
            log.warning("Scene move failed", "mover", _mover.who(), "sceneId", scene.getId(), ie);
            _listener.requestFailed(ie.getMessage());
        }
    }

    protected int _portalId;
    protected OrthLocation _destLoc;
    protected SocializerObject _memobj;
    protected BodyObject _mover;
    protected PetObject _petobj;

    // ORTH TODO -- A lot later
    // @Inject protected PetManager _petMan;
}
