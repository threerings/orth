//
// $Id: ActorInfo.java 16914 2009-05-27 05:54:19Z mdb $

package com.threerings.orth.scene.data;

import com.samskivert.util.ObjectUtil;
import com.threerings.io.SimpleStreamableObject;

/** The streamable definition of a piece of furniture in a room. */
public class FurniData extends SimpleStreamableObject
{
    /** The id of this piece of furni. */
    public short id;

    /** Identifies the item that was used to create this. */
    public EntityIdent item;

    /** Info about the media that represents this piece of furni. */
    public EntityMedia media;

    /** The location in the scene. */
    public OrthLocation loc;

    /** Layout information, used for perspectivization, etc. */
    public byte layoutInfo;

    /** A scale factor in the X direction. */
    public float scaleX = 1f;

    /** A scale factor in the Y direction. */
    public float scaleY = 1f;

    /** Rotation angle in degrees. */
    public float rotation = 0f;

    /** The x location of this furniture's hot spot. */
    public short hotSpotX;

    /** The y location of this furniture's hot spot. */
    public short hotSpotY;

    /** The type of action, determines how to use actionData. */
    public FurniAction actionType;

    /** The action, interpreted using actionType. */
    public String actionData;

    public FurniData ()
    {
        super();
    }

    public Comparable<?> getKey ()
    {
        return id;
    }

    /**
     * @return true if the other FurniData is identical.
     */
    public boolean equivalent (FurniData that)
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
            ObjectUtil.equals(this.actionData, that.actionData);
    }

    @Override
    public boolean equals (Object other)
    {
        return (other instanceof FurniData) && ((FurniData) other).id == this.id;
    }

    @Override
    public int hashCode ()
    {
        return id;
    }

    @Override
    public String toString ()
    {
        String s = "Furni[id=" + id + ", item=" + item + ", actionType=" + actionType;
        if (actionType != null) {
            s += ", actionData=\"" + actionData + "\"";
        }
        s += "]";
        return s;
    }

    @Override
    public FurniData clone ()
    {
        try {
            return (FurniData) super.clone();
        } catch (CloneNotSupportedException cnse) {
            throw new AssertionError(cnse); // not going to happen
        }
    }
}
