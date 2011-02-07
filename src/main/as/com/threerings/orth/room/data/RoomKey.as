//
// $Id$

package com.threerings.orth.room.data {

import com.threerings.orth.world.data.PlaceKey;

public class RoomKey extends PlaceKey
{
    public var sceneId :int;

    public function RoomKey (sceneId :int = 0)
    {
        this.sceneId = sceneId;
    }

    // from PlaceKey
    override public function getPlaceType () :String
    {
        return OrthRoomCodes.ROOM_PLACE_TYPE;
    }
}
}
