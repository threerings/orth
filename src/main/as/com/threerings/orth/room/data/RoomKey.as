//
// $Id$

package com.threerings.orth.room.data {

import com.threerings.orth.world.data.PlaceKey;

import OrthRoomCodes;

public class RoomKey
    implements PlaceKey
{
    public var sceneId :int;

    public function RoomKey (sceneId :int = 0)
    {
        this.sceneId = sceneId;
    }

    // from PlaceKey
    public function getPlaceType () :String
    {
        return OrthRoomCodes.ROOM_PLACE_TYPE;
    }
}
}
