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
