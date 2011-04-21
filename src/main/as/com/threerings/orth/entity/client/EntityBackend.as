//
// $Id: EntityBackend.as 19622 2010-11-23 22:59:49Z zell $

package com.threerings.orth.entity.client {
import flash.display.DisplayObject;
import flash.media.Camera;
import flash.media.Microphone;

import com.threerings.util.Log;

import com.threerings.orth.client.ControlBackend;
import com.threerings.orth.room.client.RoomView;
import com.threerings.orth.room.data.OrthLocation;

public class EntityBackend extends ControlBackend
{
    public static const MAX_KEY_LENGTH :int = 64;

    public static const log :Log = Log.getLog(EntityBackend);

    /**
     * More initialization: set the sprite we control.
     */
    public function setSprite (sprite :EntitySprite) :void
    {
        _sprite = sprite;
    }

    // from ControlBackend
    override public function shutdown () :void
    {
        super.shutdown();

        // disconnect the sprite so that badly-behaved usercode cannot touch it anymore
        _sprite = null;
    }

    public function toString () :String
    {
        return "[EntityBackend, sprite=" + _sprite + "]"
    }

    override protected function populateControlProperties (o :Object) :void
    {
        super.populateControlProperties(o);

        // we give usercode functions in the backend (instead of connecting them directly) so that
        // we can easily disconnect the sprite from the usercode
        o["lookupMemory_v1"] = lookupMemory_v1;
        o["updateMemory_v1"] = updateMemory_v1;
        o["getInstanceId_v1"] = getInstanceId_v1;
        o["getViewerName_v1"] = getViewerName_v1;
        o["setHotSpot_v1"] = setHotSpot_v1;
        o["sendMessage_v1"] = sendMessage_v1;
        o["sendSignal_v1"] = sendSignal_v1;
        o["getRoomBounds_v1"] = getRoomBounds_v1;
        o["canEditRoom_v1"] = canEditRoom_v1;
        o["showPopup_v1"] = showPopup_v1;
        o["clearPopup_v1"] = clearPopup_v1;
        o["getMemories_v1"] = getMemories_v1;
        o["getCamera_v1"] = getCamera_v1;
        o["getMicrophone_v1"] = getMicrophone_v1;
        o["selfDestruct_v1"] = selfDestruct_v1;

        o["getEntityIds_v1"] = getEntityIds_v1;
        o["getEntityProperty_v1"] = getEntityProperty_v1;
        o["getMyEntityId_v1"] = getMyEntityId_v1;

        // deprecated methods
        o["triggerEvent_v1"] = triggerEvent_v1;
    }

    override protected function populateControlInitProperties (o :Object) :void
    {
        super.populateControlInitProperties(o);

        var loc :OrthLocation = _sprite.getLocation();
        o["location"] = [ loc.x, loc.y, loc.z ];
        o["env"] = _sprite.getEnvironment();
    }

    protected function selfDestruct_v1 () :void
    {
        if (_sprite != null) {
            throw new Error("selfDestruct not implemented");
        }
    }

    protected function getEntityIds_v1 (type :String) :Array
    {
        return (_sprite == null) ? null : _sprite.getEntityIds(type);
    }

    protected function getEntityProperty_v1 (entityId :String, key :String) :Object
    {
        return (_sprite == null) ? null : _sprite.getEntityProperty(entityId, key);
    }

    protected function getMyEntityId_v1 () :String
    {
        return (_sprite == null) ? null : _sprite.getEntityIdent().toString();
    }

    protected function getCamera_v1 (index :String = null) :Camera
    {
        return Camera.getCamera(index);
    }

    protected function getMicrophone_v1 (index :int = -1) :Microphone
    {
        return Microphone.getMicrophone(index);
    }

    protected function getInstanceId_v1 () :int
    {
        return (_sprite == null) ? -1 : _sprite.getInstanceId();
    }

    protected function getViewerName_v1 (instanceId :int = 0) :String
    {
        return (_sprite == null) ? null : _sprite.getViewerName(instanceId);
    }

    protected function getMemories_v1 () :Object
    {
        return (_sprite == null) ? null : _sprite.getMemories();
    }

    protected function lookupMemory_v1 (key :String) :Object
    {
        return (_sprite == null) ? null : _sprite.lookupMemory(key);
    }

    /**
     */
    protected function updateMemory_v1 (key :String, value :Object, callback :Function) :void
    {
        if (_sprite != null) {
            _sprite.updateMemory(key, value, callback);
        }
    }

    protected function setHotSpot_v1 (x :Number, y :Number, height :Number = NaN) :void
    {
        if (_sprite != null) {
            _sprite.setHotSpot(x, y, height);
        }
    }

    protected static function validateKeyName (name :String) :void
    {
        if (name != null && name.length > MAX_KEY_LENGTH) {
            throw new ArgumentError("Key names may only be a maximum of " + MAX_KEY_LENGTH +
                " characters");
        }
    }

    protected function sendMessage_v1 (name :String, arg :Object, isAction :Boolean) :void
    {
        if (_sprite != null) {
            validateKeyName(name);
           _sprite.sendMessage(name, arg, isAction);
        }
    }

    protected function sendSignal_v1 (name :String, arg :Object) :void
    {
        if (_sprite != null) {
            validateKeyName(name);
            _sprite.sendSignal(name, arg);
        }
    }

    protected function getRoomBounds_v1 () :Array
    {
        return (_sprite == null) ? [ 1, 1, 1] : _sprite.getRoomBounds();
    }

    // note: the original version of this method took no args, which is why we now
    // have a default value.
    protected function canEditRoom_v1 (memberId :int = 0) :Boolean
    {
        return (_sprite != null) && _sprite.canManageRoom(memberId);
    }

    protected function showPopup_v1 (
        title :String, panel :DisplayObject, w :Number, h :Number,
        color :uint = 0xFFFFFF, alpha :Number = 1.0) :Boolean
    {
        if (_sprite == null || !(_sprite.viz.parent is RoomView)) {
            return false;
        }
        throw new Error("not implemented in Orth");
    }

    protected function clearPopup_v1 () :void
    {
        throw new Error("not implemented in Orth");
    }

    // Deprecated on 2007-03-12
    protected function triggerEvent_v1 (event :String, arg :Object = null) :void
    {
        validateKeyName(event);
        sendMessage_v1(event, arg, true);
    }

    /** The sprite that this backend is connected to. */
    protected var _sprite :EntitySprite;
}
}
