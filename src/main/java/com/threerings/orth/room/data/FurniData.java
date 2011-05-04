//
// $Id$

package com.threerings.orth.room.data;

import com.samskivert.util.ObjectUtil;
import com.threerings.io.SimpleStreamableObject;
import com.threerings.orth.data.MediaDesc;

/** The streamable definition of a piece of furniture in a room. */
public class FurniData extends SimpleStreamableObject
{
    /** The id of this piece of furni. */
    public short id;

    /** Identifies the item that was used to create this. */
    public EntityIdent item;

    /** Info about the media that represents this piece of furni. */
    public MediaDesc media;

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
     * Set whether or not this furni doesn't scale.
     */
    public void setNoScale (boolean noscale)
    {
        setLayoutInfo(NOSCALE_FLAG, noscale);
    }

    /**
     * Is this furniture non-scaling?
     */
    public boolean isNoScale ()
    {
        return isLayoutInfo(NOSCALE_FLAG);
    }

    /**
     * Set whether or not this furni is a parallax element.
     */
    public void setParallax (boolean parallax)
    {
        setLayoutInfo(PARALLAX_FLAG, parallax);
    }

    /**
     * Is this furniture a parallax element?
     */
    public boolean isParallax ()
    {
        return isLayoutInfo(PARALLAX_FLAG);
    }

    /**
     * Set whether or not this furni is a static element, i.e. it does not animate.
     * This is only useful for live content, i.e. SWF's.
     */
    public void setStatic (boolean isStatic)
    {
        setLayoutInfo(STATIC_FLAG, isStatic);
    }

    /**
     * Is this furniture non-static?
     * This is only useful for live content, i.e. SWF's.
     */
    public boolean isStatic ()
    {
        return isLayoutInfo(STATIC_FLAG);
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

    /**
     * Set a layoutInfo flag on or off.
     */
    protected void setLayoutInfo (int flag, boolean on)
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
    protected boolean isLayoutInfo (int flag)
    {
        return (layoutInfo & flag) != 0;
    }

    protected static final int NOSCALE_FLAG = (1 << 0);
    protected static final int PARALLAX_FLAG = (1 << 1);
    protected static final int STATIC_FLAG = (1 << 2);
}
