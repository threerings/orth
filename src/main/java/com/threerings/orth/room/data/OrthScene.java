//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.room.data;

import java.util.Iterator;

import com.threerings.crowd.data.PlaceConfig;

import com.threerings.whirled.data.SceneImpl;
import com.threerings.whirled.data.SceneModel;
import com.threerings.whirled.spot.data.Portal;
import com.threerings.whirled.spot.data.SpotScene;

public class OrthScene extends SceneImpl
    implements SpotScene
{
    public OrthScene (SceneModel model, PlaceConfig config)
    {
        super(model, config);
        _orthModel = (OrthSceneModel) model;
    }

    public OrthScene ()
    {
        super();
    }

    /**
     * Returns the type of the scene.
     */
    public byte getSceneType ()
    {
        return _orthModel.decor.getDecorType();
    }

    /**
     * Returns the "pixel" depth of the scene.
     */
    public short getDepth ()
    {
        return _orthModel.decor.getDepth();
    }

    /**
     * Returns the pixel width of the scene.
     */
    public short getWidth ()
    {
        return _orthModel.decor.getWidth();
    }

    /**
     * Get the height of the horizon, expressed as a floating
     * point number between 0 and 1. (1 == horizon at top of screen)
     */
    public float getHorizon ()
    {
        return _orthModel.decor.getHorizon();
    }

    /**
     * Retrieve the room entrance.
     */
    public OrthLocation getEntrance ()
    {
        return _orthModel.entrance;
    }

    /**
     * Retrieve the decor geometry information.
     */
    public DecorData getDecorData ()
    {
        return _orthModel.decor;
    }

    /**
     * Add the specified furniture to the scene.
     */
    public void addFurni (FurniData furn)
    {
        _orthModel.addFurni(furn);
    }

    /**
     * Remove the specified furniture from the scene.
     */
    public void removeFuni (FurniData furn)
    {
        _orthModel.removeFurni(furn);
    }

    /**
     * Get all the furniture currently in the scene.
     */
    public FurniData[] getFurni ()
    {
        return _orthModel.furnis;
    }

    /**
     * Get the next available furni id.
     */
    public short getNextFurniId (short aboveId)
    {
        return _orthModel.getNextFurniId(aboveId);
    }

    // from SpotScene
    public void addPortal (Portal portal)
    {
        throw new UnsupportedOperationException();
    }

    // from SpotScene
    public Portal getDefaultEntrance ()
    {
        return _orthModel.getDefaultEntrance();
    }

    // from SpotScene
    public short getNextPortalId ()
    {
        throw new UnsupportedOperationException();
    }

    // from SpotScene
    public Portal getPortal (int portalId)
    {
        return _orthModel.getPortal(portalId);
    }

    // from SpotScene
    public int getPortalCount ()
    {
        return _orthModel.getPortalCount();
    }

    // from SpotScene
    public Iterator<Portal> getPortals ()
    {
        return _orthModel.getPortals();
    }

    // from SpotScene
    public void removePortal (Portal portal)
    {
        throw new UnsupportedOperationException();
    }

    // from SpotScene
    public void setDefaultEntrance (Portal portal)
    {
        throw new UnsupportedOperationException();
    }

    /** A reference to our scene model. */
    protected OrthSceneModel _orthModel;
}
