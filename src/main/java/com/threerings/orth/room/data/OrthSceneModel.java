package com.threerings.orth.room.data;

import java.util.Iterator;
import java.util.Map;

import com.google.common.collect.Maps;
import com.samskivert.util.ArrayUtil;
import com.samskivert.util.ListUtil;

import com.threerings.util.Name;
import com.threerings.whirled.data.SceneModel;
import com.threerings.whirled.spot.data.Portal;

import com.threerings.orth.data.MediaDesc;
import com.threerings.orth.data.MediaMimeTypes;
import com.threerings.orth.data.URLMediaDesc;
import com.threerings.orth.entity.data.Decor;
import com.threerings.orth.entity.data.DecorObject;
import com.threerings.orth.room.data.DecorCodes;
import com.threerings.orth.room.data.OrthLocation;

import static com.threerings.orth.Log.log;

/**
 *
 */
public class OrthSceneModel extends SceneModel
{
    /** Constant for Member room owners **/
    public static final byte OWNER_TYPE_MEMBER = 1;

    /** Constant for Group room owners **/
    public static final byte OWNER_TYPE_GROUP = 2;

    /** Access control constant, denotes that anyone can enter this scene. */
    public static final byte ACCESS_EVERYONE = 0;

    /** Access control constant, denotes that only the scene owner and friends
     *  (or group manager and members, in case of a group scene) can enter this scene. */
    public static final byte ACCESS_OWNER_AND_FRIENDS = 1;

    /** Access control constant, denotes that only the scene owner (or group manager,
     *  in case of a group scene) can enter this scene. */
    public static final byte ACCESS_OWNER_ONLY = 2;

    /** The default decor URL. */
    public static final String DEFAULT_DECOR_URL = "http://www.alyx.com/zell/pics/decor.jpg";

    /** The default decor media. */
    public static final MediaDesc DEFAULT_DECOR_MEDIA = new URLMediaDesc(
        DEFAULT_DECOR_URL, MediaMimeTypes.IMAGE_JPEG, MediaDesc.NOT_CONSTRAINED);

    /** Access control, as one of the ACCESS constants. Limits who can enter the scene. */
    public byte accessControl;

    /** The type of owner that owns this scene. */
    public byte ownerType;

    /** The id of the owner of this scene, interpreted using ownerType. */
    public int ownerId;

    /** The name of the owner, either a MemberName or GroupName. */
    public Name ownerName;

    /** The furniture in the scene. */
    public FurniData[] furnis = new FurniData[0];

    /** The entrance location. */
    public OrthLocation entrance;

    /** Decor item reference. */
    public EntityIdent decorIdent;

    /** Decor information. */
    public Decor decor;

    public OrthSceneModel ()
    {
        super();
    }

    /**
     * Add a piece of furniture to this model.
     */
    public void addFurni (FurniData furni)
    {
        furnis = ArrayUtil.append(furnis, furni);
        invalidatePortalInfo(furni);
    }

    /**
     * Remove a piece of furniture from this model.
     */
    public void removeFurni (FurniData furni)
    {
        int idx = ListUtil.indexOf(furnis, furni);
        if (idx != -1) {
            furnis = ArrayUtil.splice(furnis, idx, 1);
            invalidatePortalInfo(furni);
        }
    }

    /**
     * Updates a piece of furniture in this model.
     */
    public void updateFurni (FurniData data)
    {
        int idx = ListUtil.indexOf(furnis, data);
        if (idx != -1) {
            furnis[idx] = data;
            invalidatePortalInfo(data);
        } else {
            log.warning("Requested to update furni not in scene [id=" + sceneId + ", name=" + name +
                        ", furni=" + data + "].");
        }
    }

    /**
     * Get the next available furni id.
     */
    public short getNextFurniId (short aboveId)
    {
        int length = (furnis == null) ? 0 : furnis.length;
        for (int ii=aboveId + 1; ii != aboveId; ii++) {
            if (ii > Short.MAX_VALUE) {
                ii = Short.MIN_VALUE;
                if (ii == aboveId) {
                    break;
                }
            }
            boolean found = false;
            for (int idx=0; idx < length; idx++) {
                if (furnis[idx].id == ii) {
                    found = true;
                    break;
                }
            }
            if (!found) {
                return (short) ii;
            }
        }
        return (short) -1;
    }

    /**
     * Support for SpotScene.
     */
    public Portal getDefaultEntrance ()
    {
        Portal p = new Portal();
        p.portalId = (short) -1;
        p.loc = entrance;
        p.targetSceneId = sceneId;
        p.targetPortalId = -1;

        return p;
    }

    /**
     * Support for SpotScene.
     */
    public Portal getPortal (int portalId)
    {
        validatePortalInfo();
        return _portalInfo.get(Short.valueOf((short) portalId));
    }

    /**
     * Support for SpotScene.
     */
    public int getPortalCount ()
    {
        validatePortalInfo();
        return _portalInfo.size();
    }

    /**
     * Support for SpotScene.
     */
    public Iterator<Portal> getPortals ()
    {
        validatePortalInfo();
        return _portalInfo.values().iterator();
    }

    /**
     * Create a blank scene, with default decor data.
     */
    public static OrthSceneModel blankOrthSceneModel ()
    {
        OrthSceneModel model = new OrthSceneModel();
        model.accessControl = OrthSceneModel.ACCESS_EVERYONE;
        model.entrance = new OrthLocation(.5, 0, .5, 180);
        model.decor = defaultOrthSceneModelDecor();
        populateBlankOrthSceneModel(model);
        return model;
    }

    /**
     * Create a default decor for a blank scene. The decor will not be completely filled in,
     * because it doesn't correspond to an entity inside the database, but it has enough to be
     * displayed inside the room.
     */
    public static Decor defaultOrthSceneModelDecor ()
    {
        DecorObject decor = new DecorObject();
        decor.media = DEFAULT_DECOR_MEDIA;
        decor.type = DecorCodes.IMAGE_OVERLAY;
        decor.width = 800;
        decor.height = 500;
        decor.depth = 400;
        decor.horizon = .5f;
        decor.actorScale = 1;
        decor.furniScale = 1;
        return decor;
    }

    protected static void populateBlankOrthSceneModel (OrthSceneModel model)
    {
        populateBlankSceneModel(model);
    }

    /**
     * Invalidate our portal info if the specified piece of furniture is a portal.
     */
    protected void invalidatePortalInfo (FurniData changedFurni)
    {
        if (changedFurni.actionType.isPortal()) {
            invalidatePortalInfo();
        }
    }

    /**
     * Invalidate our cached portal info.
     */
    protected void invalidatePortalInfo ()
    {
        _portalInfo = null;
    }

    /**
     * Validate that the portalInfo is up-to-date and ready to use.
     */
    protected void validatePortalInfo ()
    {
        // if non-null, we're already valid
        if (_portalInfo != null) {
            return;
        }

        _portalInfo = Maps.newHashMap();
        for (FurniData furni : furnis) {
            if (furni.actionType.isPortal()) {
                try {
                    OrthPortal p = new OrthPortal(furni);
                    _portalInfo.put(p.portalId, p);
                } catch (Exception e) {
                    log.warning("Invalid portal furni [fd=" + furni + "].", e);
                }
            }
        }
    }

    /** Cached portal info. */
    protected transient Map<Short, Portal> _portalInfo;
}
