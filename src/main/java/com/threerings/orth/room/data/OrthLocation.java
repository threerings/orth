//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.room.data;

import com.threerings.io.Streamable;

import com.threerings.whirled.spot.data.Location;

/**
 * Extends basic the basic Location with a z-coordinate.
 */
public class OrthLocation
    implements Location, Streamable
{
    /** The body's x position (interpreted by the display system). */
    public float x;

    /** The body's y position (interpreted by the display system). */
    public float y;

    /** The body's z position (interpreted by the display system). */
    public float z;

    /** The body's orientation (interpreted by the display system). */
    public short orient;

    /** Suitable for unserialization. */
    public OrthLocation ()
    {
    }

    /**
     * Constructs a fully-specified Location.
     */
    public OrthLocation (double x, double y, double z, int orient)
    {
        this.x = (float) x;
        this.y = (float) y;
        this.z = (float) z;
        this.orient = (short) orient;
    }

    /**
     * Get the distance between this location and the other.
     */
    public double distance (OrthLocation that)
    {
        float dx = this.x - that.x;
        float dy = this.y - that.y;
        float dz = this.z - that.z;

        return Math.sqrt(dx*dx + dy*dy + dz*dz);
    }

    // documentation inherited from interface Location
    public OrthLocation getOpposite ()
    {
        OrthLocation l = clone();
        // rotated 180 degrees
        l.orient = (short) ((orient + 180) % 360);
        return l;
    }

    // documentation inherited from interface Location
    public boolean equivalent (Location other)
    {
        return equals(other) &&
            (orient == ((OrthLocation) other).orient);
    }

    @Override
    public OrthLocation clone ()
    {
        try {
            return (OrthLocation) super.clone();
        } catch (CloneNotSupportedException cnse) {
            throw new AssertionError(cnse);
        }
    }

    @Override
    public boolean equals (Object other)
    {
        if (other instanceof OrthLocation) {
            OrthLocation that = (OrthLocation)other;
            return (this.x == that.x) && (this.y == that.y) &&
                (this.z == that.z);
        }
        return false;
    }

    @Override
    public int hashCode ()
    {
        return ((int) x) ^ ((int) y) ^ ((int) z);
    }

    @Override
    public String toString ()
    {
        return "[(" + x + ", " + y + ", " + z + ")/" + orient + "°]";
    }
}
