//
// $Id: OrthSceneModel.as 18842 2009-12-11 20:38:56Z zell $

package com.threerings.orth.room.data {

import com.threerings.util.ArrayIterator;
import com.threerings.util.ArrayUtil;
import com.threerings.util.Iterator;
import com.threerings.util.Map;
import com.threerings.util.Maps;
import com.threerings.util.Name;
import com.threerings.util.Short;

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;
import com.threerings.io.TypedArray;

import com.threerings.whirled.data.SceneModel;

import com.threerings.whirled.spot.data.Portal;

public class OrthSceneModel extends SceneModel
{
    /** Constant for Member room owners **/
    public static const OWNER_TYPE_MEMBER :int = 1;

    /** Constant for Group room owners **/
    public static const OWNER_TYPE_GROUP :int = 2;

    /** Access control constant, denotes that anyone can enter this scene. */
    public static const ACCESS_EVERYONE :int = 0;

    /** Access control constant, denotes that only the scene owner and friends
     *  (or group manager and members, in case of a group scene) can enter this scene. */
    public static const ACCESS_OWNER_AND_FRIENDS :int = 1;

    /** Access control constant, denotes that only the scene owner (or group manager,
     *  in case of a group scene) can enter this scene. */
    public static const ACCESS_OWNER_ONLY :int = 2;

    /** The maximum length of a room name. */
    public static const MAX_NAME_LENGTH :int = 80;

    /** Access control, as one of the ACCESS constants. Limits who can enter the scene. */
    public var accessControl :int;

    /** The type of owner that owns this scene. */
    public var ownerType :int;

    /** The id of the owner of this scene, interpreted using ownerType. */
    public var ownerId :int;

    /** The name of the owner, either a OrthName or the group's name. */
    public var ownerName :Name;

    /** The furniture in the scene. */
    public var furnis :TypedArray /* of FurniData */;

    /** The entrance location. */
    public var entrance :OrthLocation;

    /** Decor item reference. */
    public var decorIdent :EntityIdent;

    /** Decor item geometry. */
    public var decorInfo :Decor;

    /** Constructor. */
    public function OrthSceneModel ()
    {
    }

    /**
     * Add a piece of furniture to this model.
     */
    public function addFurni (furni :FurniData) :void
    {
        furnis.push(furni);
        invalidatePortalInfo(furni);
    }

    /**
     * Remove a piece of furniture to this model.
     */
    public function removeFurni (furni :FurniData) :void
    {
        ArrayUtil.removeFirst(furnis, furni);
        invalidatePortalInfo(furni);
    }

    /**
     * Get the next available furni id.
     */
    public function getNextFurniId (aboveId :int) :int
    {
        if (aboveId > Short.MAX_VALUE || aboveId < Short.MIN_VALUE) {
            aboveId = Short.MIN_VALUE;
        }
        var length :int = (furnis == null) ? 0 : furnis.length;
        for (var ii :int = aboveId + 1; ii != aboveId; ii++) {
            if (ii > Short.MAX_VALUE) {
                ii = Short.MIN_VALUE;
                if (ii == aboveId) {
                    break;
                }
            }
            var found :Boolean = false;
            for (var idx :int = 0; idx < length; idx++) {
                if ((furnis[idx] as FurniData).id == ii) {
                    found = true;
                    break;
                }
            }
            if (!found) {
                return ii;
            }
        }
        return -1;
    }

    /**
     * Support for SpotScene.
     */
    public function getDefaultEntrance () :Portal
    {
        var p :Portal = new Portal();
        p.portalId = -1;
        p.loc = entrance;
        p.targetSceneId = sceneId;
        p.targetPortalId = -1;

        return p;
    }

    /**
     * Support for SpotScene.
     */
    public function getPortal (portalId :int) :Portal
    {
        validatePortalInfo();
        return (_portalInfo.get(portalId) as Portal);
    }

    /**
     * Support for SpotScene.
     */
    public function getPortalCount () :int
    {
        validatePortalInfo();
        return _portalInfo.size();
    }

    /**
     * Support for SpotScene.
     */
    public function getPortals () :Iterator
    {
        validatePortalInfo();
        return new ArrayIterator(_portalInfo.values());
    }

    /**
     * Invalidate our portal info if the specified piece of furniture
     * is a portal.
     */
    protected function invalidatePortalInfo (
        changedFurni :FurniData = null) :void
    {
        if (changedFurni == null || changedFurni.actionType.isPortal()) {
            _portalInfo = null;
        }
    }

    /**
     * Validate that the portalInfo is up-to-date and ready to use.
     */
    protected function validatePortalInfo () :void
    {
        // if non-null, we're already valid
        if (_portalInfo != null) {
            return;
        }

        _portalInfo = Maps.newMapOf(int);
        for each (var furni :FurniData in furnis) {
            if (furni.actionType.isPortal()) {
                var p :OrthPortal = new OrthPortal(furni);
                _portalInfo.put(p.portalId, p);
            }
        }
    }

    override public function clone () :Object
    {
        var model :OrthSceneModel = (super.clone() as OrthSceneModel);
        model.accessControl = accessControl;
        model.ownerType = ownerType;
        model.ownerId = ownerId;
        model.ownerName = ownerName;
        model.furnis = (furnis.clone() as TypedArray);
        model.entrance = (entrance.clone() as OrthLocation);
        model.decorIdent = decorIdent;
        model.decorInfo = decorInfo;
        return model;
    }

    // documentation inherited
    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);

        out.writeByte(accessControl);
        out.writeByte(ownerType);
        out.writeInt(ownerId);
        out.writeObject(ownerName);
        out.writeObject(furnis);
        out.writeObject(entrance);
        out.writeObject(decorIdent);
        out.writeObject(decorInfo);
    }

    // documentation inherited
    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);

        accessControl = ins.readByte();
        ownerType = ins.readByte();
        ownerId = ins.readInt();
        ownerName = Name(ins.readObject());
        furnis = TypedArray(ins.readObject());
        entrance = OrthLocation(ins.readObject());
        decorIdent = EntityIdent(ins.readObject());
        decorInfo = Decor(ins.readObject());
    }

    /** Cached portal info. Not streamed. */
    protected var _portalInfo :Map;
}
}
