//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.
package com.threerings.orth.room.data {
import flash.errors.IllegalOperationError;

import com.threerings.crowd.data.PlaceConfig;
import com.threerings.whirled.data.SceneImpl;
import com.threerings.whirled.spot.data.Portal;
import com.threerings.whirled.spot.data.SpotScene;

import com.threerings.util.Cloneable;
import com.threerings.util.Iterator;

import com.threerings.orth.aether.data.PlayerObject;

public class OrthScene extends SceneImpl
    implements SpotScene, Cloneable
{
    public function OrthScene (model :OrthSceneModel, config :PlaceConfig)
    {
        super(model, config);
        _orthModel = model;
    }

    /**
     * Does the specified member have management rights in this room?
     */
    public function canManage (member :PlayerObject, allowSupport :Boolean = true) :Boolean
    {
        // ORTH TODO
        return true;

        var hasRights :Boolean;
        switch (_orthModel.ownerType) {
        case OrthSceneModel.OWNER_TYPE_MEMBER:
            hasRights = (_orthModel.ownerId == member.getPlayerId());
            break;

        default:
            hasRights = false;
            break;
        }

        return hasRights;
    }

    /**
     * Returns the scene type.
     */
    public function getSceneType () :int
    {
        return _orthModel.decor.type;
    }

    /**
     * Returns the "pixel" depth of the scene.
     */
    public function getDepth () :int
    {
        return _orthModel.decor.depth;
    }

    /**
     * Returns the pixel width of the scene.
     */
    public function getWidth () :int
    {
        return _orthModel.decor.width;
    }

    public function getHeight () :int
    {
        return _orthModel.decor.height;
    }

    /**
     * Get the height of the horizon, expressed as a floating
     * point number between 0 and 1. (1 == horizon at top of screen)
     */
    public function getHorizon () :Number
    {
        return _orthModel.decor.horizon;
    }

    /**
     * Retrieve the room entrance.
     */
    public function getEntrance () :OrthLocation
    {
        return _orthModel.entrance;
    }

    /**
     * Retrieve the room decor information object.
     */
    public function getDecor () :DecorData
    {
        return _orthModel.decor;
    }

    /**
     * Add a new piece of furniture to this scene.
     */
    public function addFurni (furn :FurniData) :void
    {
        _orthModel.addFurni(furn);
    }

    /**
     * Remove a piece of furniture from this scene.
     */
    public function removeFurni (furn :FurniData) :void
    {
        _orthModel.removeFurni(furn);
    }

    /**
     * Get all the furniture currently in the scene.
     */
    public function getFurni () :Array
    {
        return _orthModel.furnis;
    }

    /**
     * Get the next available furniture id.
     */
    public function getNextFurniId (aboveId :int) :int
    {
        return _orthModel.getNextFurniId(aboveId);
    }

    // from SpotScene
    public function addPortal (portal :Portal) :void
    {
        throw new IllegalOperationError();
    }

    // from SpotScene
    public function getDefaultEntrance () :Portal
    {
        return _orthModel.getDefaultEntrance();
    }

    // from SpotScene
    public function getNextPortalId () :int
    {
        throw new IllegalOperationError();
    }

    // from SpotScene
    public function getPortal (portalId :int) :Portal
    {
        return _orthModel.getPortal(portalId);
    }

    // from SpotScene
    public function getPortalCount () :int
    {
        return _orthModel.getPortalCount();
    }

    // from SpotScene
    public function getPortals () :Iterator
    {
        return _orthModel.getPortals();
    }

    // from SpotScene
    public function removePortal (portal :Portal) :void
    {
        throw new IllegalOperationError();
    }

    // from SpotScene
    public function setDefaultEntrance (portal :Portal) :void
    {
        throw new IllegalOperationError();
    }

    // from Cloneable
    public function clone () :Object
    {
        return new OrthScene(_orthModel.clone() as OrthSceneModel, _config);
    }

    /** A reference to our scene model. */
    protected var _orthModel :OrthSceneModel;
}
}
