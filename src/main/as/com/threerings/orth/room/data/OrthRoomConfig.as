// GENERATED PREAMBLE START
//
// $Id$

package com.threerings.orth.room.data {

import com.threerings.crowd.data.PlaceConfig;

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

// GENERATED PREAMBLE END
// GENERATED CLASSDECL START
public class OrthRoomConfig extends PlaceConfig
{
// GENERATED CLASSDECL END
// GENERATED STREAMING START
    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
    }

// GENERATED STREAMING END
// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END
//
// $Id: RoomConfig.as 10500 2008-08-07 19:14:38Z mdb $

package com.threerings.orth.room.data {

import com.threerings.crowd.client.PlaceController;
import com.threerings.crowd.data.PlaceConfig;

import com.threerings.orth.room.client.RoomObjectController;

public class OrthRoomConfig extends PlaceConfig
{
    // documentation inherited
    override public function createController () :PlaceController
    {
        return new RoomObjectController();
    }
}
}
