//
// $Id: ActorInfo.java 16914 2009-05-27 05:54:19Z mdb $

package com.threerings.orth.room.data {
import com.threerings.orth.data.MediaDesc;
import com.threerings.util.ClassUtil;
import com.threerings.util.Cloneable;
import com.threerings.util.Hashable;
import com.threerings.util.Util;

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;
import com.threerings.io.SimpleStreamableObject;

import com.threerings.presents.dobj.DSet_Entry;

public class FurniData extends SimpleStreamableObject
    implements Cloneable, Hashable, DSet_Entry
{
    /** The id of this piece of furni. */
    public var id :int;

    /** Identifies the item that was used to create this. */
    public var item :EntityIdent;

    /** Info about the media that represents this piece of furni. */
    public var media :MediaDesc;

    /** The location in the scene. */
    public var loc :OrthLocation;

    /** Layout information, used for perspectivization, etc. */
    public var layoutInfo :int;

    /** A scale factor in the X direction. */
    public var scaleX :Number = 1.0;

    /** A scale factor in the Y direction. */
    public var scaleY :Number = 1.0;

    /** Rotation angle in degrees. */
    public var rotation :Number = 0.0;

    /** The x location of this furniture's hot spot. */
    public var hotSpotX :int;

    /** The y location of this furniture's hot spot. */
    public var hotSpotY :int;

    /** The type of action, determines how to use actionData. */
    public var actionType :FurniAction;

    /** The action, interpreted using actionType. */
    public var actionData :String;

    // from DSet_Entry
    public function getKey () :Object
    {
        return id;
    }

    // from superinterface Equalable
    public function equals (other :Object) :Boolean
    {
        return (other is FurniData) && (other as FurniData).id == this.id;
    }

    public function hashCode () :int
    {
        return id;
    }

    public function clone () :Object
    {
        // just a shallow copy at present
        var that :FurniData = (ClassUtil.newInstance(this) as FurniData);
        that.copyFrom(this);
        return that;
    }

    /**
     * Return the actionData as strings separated by colons. If there is not at least one colon,
     * then a single-element array is returned.
     */
    public function splitActionData () :Array
    {
        if (actionData == null) {
            return [ null ];
        }
        var sep :String = actionType.isURL() ? "||" : ":";
        var sepDex :int = actionData.indexOf(sep);
        if (sepDex == -1) {
            return [ actionData ];
        }
        if (actionType.isPortal()) {
            var data :Array = actionData.split(sep);
            if (data.length > 5) {
                // if it's a newstyle portal, the last field is the target scene name,
                // which may have colons in it.
                data[5] = data.slice(5).join(sep);
                data.length = 6; // truncate
            }
            return data;

        } else {
            return [ actionData.substring(0, sepDex),
                     actionData.substring(sepDex + sep.length) ];
            // TODO: can we just do this? will the 2 mean "stick everything in the last argument"
            // or will it mean "ignore everything after the third colon"? the documentation of
            // course does not say...
//             return actionData.split(":", 2);
        }
    }

    /** Overwrites this instance's fields with a shallow copy of the other object. */
    protected function copyFrom (that :FurniData) :void
    {
        this.id = that.id;
        this.item = that.item;
        this.media = that.media;
        this.loc = that.loc;
        this.layoutInfo = that.layoutInfo;
        this.scaleX = that.scaleX;
        this.scaleY = that.scaleY;
        this.rotation = that.rotation;
        this.hotSpotX = that.hotSpotX;
        this.hotSpotY = that.hotSpotY;
        this.actionType = that.actionType;
        this.actionData = that.actionData;
    }

    /**
     * @return true if the other FurniData is identical.
     */
    public function equivalent (that :FurniData) :Boolean
    {
        return (this.id == that.id) &&
            this.item.equals(that.item) &&
            this.media.equals(that.media) &&
            this.loc.equals(that.loc) &&
            (this.layoutInfo == that.layoutInfo) &&
            (this.scaleX == that.scaleX) &&
            (this.scaleY == that.scaleY) &&
            (this.rotation == that.rotation) &&
            (this.hotSpotX == that.hotSpotX) &&
            (this.hotSpotY == that.hotSpotY) &&
            (this.actionType == that.actionType) &&
            Util.equals(this.actionData, that.actionData);
    }

    // from interface Streamable
    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        id = ins.readShort();
        item = ins.readObject(EntityIdent);
        media = ins.readObject(MediaDesc);
        loc = ins.readObject(OrthLocation);
        layoutInfo = ins.readByte();
        scaleX = ins.readFloat();
        scaleY = ins.readFloat();
        rotation = ins.readFloat();
        hotSpotX = ins.readShort();
        hotSpotY = ins.readShort();
        actionType = ins.readObject(FurniAction);
        actionData = ins.readField(String);
    }

    // from interface Streamable
    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeShort(id);
        out.writeObject(item);
        out.writeObject(media);
        out.writeObject(loc);
        out.writeByte(layoutInfo);
        out.writeFloat(scaleX);
        out.writeFloat(scaleY);
        out.writeFloat(rotation);
        out.writeShort(hotSpotX);
        out.writeShort(hotSpotY);
        out.writeObject(actionType);
        out.writeField(actionData);
    }

}
}
