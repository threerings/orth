//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

// GENERATED PREAMBLE START
package com.threerings.orth.room.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;
import com.threerings.io.Streamable;

import com.threerings.whirled.spot.data.Location;

// GENERATED PREAMBLE END
// GENERATED CLASSDECL START
public class OrthLocation implements Location, Streamable
{
// GENERATED CLASSDECL END
    /**
     * Return the linear combination (1-t)*a + t*b, i.e. the OrthLocation at point t between
     * a and b, where 0 <= t <= 1.
     */
    public static function interpolate (a :OrthLocation, b :OrthLocation, t :Number) :OrthLocation
    {
        return new OrthLocation(
            a.x + t*(b.x - a.x),
            a.y + t*(b.y - a.y),
            a.z + t*(b.z - a.z),
            a.orient + t*(b.orient - a.orient));
    }

// GENERATED STREAMING START
    public var x :Number;

    public var y :Number;

    public var z :Number;

    public var orient :int;

    public function readObject (ins :ObjectInputStream) :void
    {
        x = ins.readFloat();
        y = ins.readFloat();
        z = ins.readFloat();
        orient = ins.readShort();
    }

    public function writeObject (out :ObjectOutputStream) :void
    {
        out.writeFloat(x);
        out.writeFloat(y);
        out.writeFloat(z);
        out.writeShort(orient);
    }

// GENERATED STREAMING END

    public function OrthLocation (x :Number = 0, y :Number = 0, z :Number = 0, orient :int = 0)
    {
        this.x = x;
        this.y = y;
        this.z = z;
        this.orient = orient;
    }

    /**
     * Set this location to the specified object's value.
     * @param newLoc may be an array or another OrthLocation.
     */
    public function set (newLoc :Object) :void
    {
        if (newLoc is OrthLocation) {
            var mloc :OrthLocation = (newLoc as OrthLocation);
            this.x = mloc.x;
            this.y = mloc.y;
            this.z = mloc.z;

        } else if (newLoc is Array) {
            var aloc :Array = (newLoc as Array);
            this.x = aloc[0];
            this.y = aloc[1];
            this.z = aloc[2];

        } else {
            throw new ArgumentError("Location may be an OrthLocation or an Array");
        }
    }

    /**
     * Get the distance between this location and the other.
     */
    public function distance (that :OrthLocation) :Number
    {
        var dx :Number = this.x - that.x;
        var dy :Number = this.y - that.y;
        var dz :Number = this.z - that.z;

        return Math.sqrt(dx*dx + dy*dy + dz*dz);
    }

    /**
     * Locations are equivalent if they have the same coordinates and orientation.
     */
    public function equivalent (oloc :Location) :Boolean
    {
        return equals(oloc) &&
            (orient == (oloc as OrthLocation).orient);
    }

    // from interface Location
    public function getOpposite () :Location
    {
        var l :OrthLocation = (clone() as OrthLocation);
        // rotated 180 degrees
        l.orient = (l.orient + 180) % 360;
        return l;
    }

    // from interface Hashable
    public function equals (other :Object) :Boolean
    {
        if (other is OrthLocation) {
            var that :OrthLocation = (other as OrthLocation);
            return (this.x == that.x) && (this.y == that.y) &&
                (this.z == that.z);
        }
        return false;
    }

    // from interface Hashable
    public function hashCode () :int
    {
        return int(x) ^ int(y) ^ int(z);
    }

    // from interface Location
    public function clone () :Object
    {
        return new OrthLocation(x, y, z, orient);
    }

    // from Object
    public function toString () :String
    {
        return "[(" + x + ", " + y + ", " + z + ")/" + orient + "°]";
    }

// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END
