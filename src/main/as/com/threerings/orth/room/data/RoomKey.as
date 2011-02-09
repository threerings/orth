// GENERATED PREAMBLE START
//
// $Id$

package com.threerings.orth.room.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

import com.threerings.orth.room.client.RoomContext;
import com.threerings.orth.world.client.WorldContext;
import com.threerings.orth.world.data.PlaceKey;

// GENERATED PREAMBLE END
// GENERATED CLASSDECL START
public class RoomKey extends PlaceKey
{
// GENERATED CLASSDECL END
// GENERATED STREAMING START
    public var sceneId :int;

    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        sceneId = ins.readInt();
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeInt(sceneId);
    }

// GENERATED STREAMING END

    public function RoomKey (sceneId :int = 0)
    {
        this.sceneId = sceneId;
    }

    /** Creates a new {@link WorldContext} subclass of the appropriate type for this place. */
    override public function createContext () :WorldContext
    {
        return new RoomContext();
    }

    // from PlaceKey
    override public function getPlaceType () :String
    {
        return OrthRoomCodes.ROOM_PLACE_TYPE;
    }

// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END
