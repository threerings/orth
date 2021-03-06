//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

// GENERATED PREAMBLE START
package com.threerings.orth.room.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;
import com.threerings.io.TypedArray;
import com.threerings.io.streamers.ArrayStreamer;

import com.threerings.util.ArrayIterator;
import com.threerings.util.Arrays;
import com.threerings.util.Iterator;
import com.threerings.util.Map;
import com.threerings.util.Maps;
import com.threerings.util.Short;

import com.threerings.whirled.data.SceneModel;
import com.threerings.whirled.spot.data.Portal;

import com.threerings.orth.room.data.DecorData;
import com.threerings.orth.room.data.OrthLocation;

// GENERATED PREAMBLE END
// GENERATED CLASSDECL START
public class OrthSceneModel extends SceneModel
{
// GENERATED CLASSDECL END
    /** The maximum length of a room name. */
    public static const MAX_NAME_LENGTH :int = 80;

// GENERATED STREAMING START
    public var furnis :TypedArray;

    public var entrances :TypedArray; /* of */ OrthLocation;

    public var decor :DecorData;

    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        furnis = ins.readObject(TypedArray);
        entrances = ins.readField(ArrayStreamer.INSTANCE);
        decor = ins.readObject(DecorData);
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeObject(furnis);
        out.writeField(entrances, ArrayStreamer.INSTANCE);
        out.writeObject(decor);
    }

// GENERATED STREAMING END

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
        Arrays.removeFirst(furnis, furni);
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
        p.loc = (entrances.length > 0) ? entrances[0] : new OrthLocation(0.5, 0, 0.5, 0);
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
        model.furnis = (furnis.clone() as TypedArray);
        model.entrances = (entrances.clone() as TypedArray);
        model.decor = decor;
        return model;
    }

    /** Cached portal info. Not streamed. */
    protected var _portalInfo :Map;
// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END
