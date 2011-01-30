package com.threerings.orth.room.data;

import java.util.Iterator;

import com.threerings.crowd.data.PlaceConfig;
import com.threerings.util.Name;
import com.threerings.whirled.data.SceneImpl;
import com.threerings.whirled.data.SceneModel;
import com.threerings.whirled.spot.data.Portal;

import com.threerings.orth.entity.data.Decor;

public class OrthScene extends SceneImpl
{
    public OrthScene (SceneModel model, PlaceConfig config)
    {
        super(model, config);
    }

    public OrthScene ()
    {
        super();
    }

    /**
     * Returns the owner id for the scene.
     */
    public int getOwnerId ()
    {
        return _orthModel.ownerId;
    }

    /**
     * Returns the name of the owner of this scene (MemberName or GroupName).
     */
    public Name getOwner ()
    {
        return _orthModel.ownerName;
    }

    /**
     * Returns the owner type for the scene.
     */
    public byte getOwnerType ()
    {
        return _orthModel.ownerType;
    }

    /**
     * Returns the access control for the scene.
     */
    public byte getAccessControl ()
    {
        return _orthModel.accessControl;
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
     * Retrieve the decor item reference.
     */
    public EntityIdent getDecorIdent ()
    {
        return _orthModel.decorIdent;
    }

    /**
     * Retrieve the decor geometry information.
     */
    public Decor getDecorInfo ()
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

    public void addPortal (Portal portal)
    {
        throw new UnsupportedOperationException();
    }

    public Portal getDefaultEntrance ()
    {
        return _orthModel.getDefaultEntrance();
    }

    public short getNextPortalId ()
    {
        throw new UnsupportedOperationException();
    }

    public Portal getPortal (int portalId)
    {
        return _orthModel.getPortal(portalId);
    }

    public int getPortalCount ()
    {
        return _orthModel.getPortalCount();
    }

    public Iterator<Portal> getPortals ()
    {
        return _orthModel.getPortals();
    }

    public void removePortal (Portal portal)
    {
        throw new UnsupportedOperationException();
    }

    public void setDefaultEntrance (Portal portal)
    {
        throw new UnsupportedOperationException();
    }

    /** A reference to our scene model. */
    protected OrthSceneModel _orthModel;
}