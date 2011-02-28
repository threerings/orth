// GENERATED PREAMBLE START
//
// $Id$

package com.threerings.orth.room.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;
import com.threerings.io.SimpleStreamableObject;

import com.threerings.orth.room.data.OrthLocation;
import com.threerings.orth.room.data.RoomKey;
import com.threerings.orth.world.data.Destination;
import com.threerings.orth.world.data.PlaceKey;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class RoomDestination extends SimpleStreamableObject
    implements Destination
{
// GENERATED CLASSDECL END
    public function RoomDestination (key :RoomKey = null, loc :OrthLocation = null)
    {
        _key = key;
        _loc = loc;
    }

    // from Destination
    public function getPlaceKey () :PlaceKey
    {
        return _key;
    }

    /**
     * The location within the destination at which we should arrive; this can be null,
     * in which case we arrive in the default starting position.
     */
    public function getLocation () :OrthLocation
    {
        return _loc;
    }

// GENERATED STREAMING START
    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        _key = ins.readObject(RoomKey);
        _loc = ins.readObject(OrthLocation);
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeObject(_key);
        out.writeObject(_loc);
    }

    protected var _key :RoomKey;
    protected var _loc :OrthLocation;
// GENERATED STREAMING END

// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END

