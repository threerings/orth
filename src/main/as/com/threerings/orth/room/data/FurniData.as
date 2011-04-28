// GENERATED PREAMBLE START
//
// $Id$


package com.threerings.orth.room.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;
import com.threerings.io.SimpleStreamableObject;

import com.threerings.util.ClassUtil;
import com.threerings.util.Joiner;
import com.threerings.util.Util;

import com.threerings.presents.dobj.DSet_Entry;

import com.threerings.orth.data.MediaDesc;
import com.threerings.orth.room.data.EntityIdent;
import com.threerings.orth.room.data.FurniAction;
import com.threerings.orth.room.data.OrthLocation;

// GENERATED PREAMBLE END
// GENERATED CLASSDECL START
public class FurniData extends SimpleStreamableObject
{
// GENERATED CLASSDECL END
// GENERATED STREAMING START
    public var id :int;

    public var item :EntityIdent;

    public var media :MediaDesc;

    public var loc :OrthLocation;

    public var layoutInfo :int;

    public var scaleX :Number = 1;

    public var scaleY :Number = 1;

    public var rotation :Number = 0;

    public var hotSpotX :int;

    public var hotSpotY :int;

    public var actionType :FurniAction;

    public var actionData :String;

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

// GENERATED STREAMING END

    /**
     * Set whether or not this furni doesn't scale.
     */
    public function setNoScale (noscale :Boolean) :void
    {
        setLayoutInfo(NOSCALE_FLAG, noscale);
    }

    /**
     * Is this furniture non-scaling?
     */
    public function isNoScale () :Boolean
    {
        return isLayoutInfo(NOSCALE_FLAG);
    }

    /**
     * Set whether or not this furni doesn't scale.
     */
    public function setParallax (parallax :Boolean) :void
    {
        setLayoutInfo(PARALLAX_FLAG, parallax);
    }

    /**
     * Is this furniture non-scaling?
     */
    public function isParallax () :Boolean
    {
        return isLayoutInfo(PARALLAX_FLAG);
    }

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

    override public function toString () :String
    {
        return Joiner.simpleToString(this);
    }

    /**
     * Set a layoutInfo flag on or off.
     */
    protected function setLayoutInfo (flag :int, on :Boolean) :void
    {
        if (on) {
            layoutInfo |= flag;
        } else {
            layoutInfo &= ~flag;
        }
    }

    /**
     * Test a layoutInfo flag.
     */
    protected function isLayoutInfo (flag :int) :Boolean
    {
        return (layoutInfo & flag) != 0;
    }

    protected static const NOSCALE_FLAG :int = (1 << 0);
    protected static const PARALLAX_FLAG :int = (1 << 1);

// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END
