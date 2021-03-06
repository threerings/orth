//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.room.data;

import java.util.Iterator;
import java.util.List;
import java.util.Map;

import com.google.common.collect.Lists;
import com.google.common.collect.Maps;

import com.samskivert.util.ArrayUtil;
import com.samskivert.util.ListUtil;

import com.threerings.whirled.data.SceneModel;
import com.threerings.whirled.spot.data.Portal;

import static com.threerings.orth.Log.log;

/**
 *
 */
public class OrthSceneModel extends SceneModel
{
    /** The furniture in the scene. */
    public FurniData[] furnis = new FurniData[0];

    public List<OrthLocation> entrances = Lists.newArrayList();

    /** Decor information. */
    public DecorData decor;

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
            log.warning("Requested to update furni not in scene", "id", sceneId, "name", name,
                "furni", data);
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
        p.loc = entrances.isEmpty() ? new OrthLocation(0.5, 0, 0.5, 0) : entrances.get(0);
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
                    log.warning("Invalid portal furni", "fd", furni, e);
                }
            }
        }
    }

    /** Cached portal info. */
    protected transient Map<Short, Portal> _portalInfo;
}
