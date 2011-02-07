//
// $Id$

package com.threerings.orth.room.data;

import com.samskivert.util.Comparators;

import com.threerings.orth.world.data.PlaceKey;

public class RoomKey extends PlaceKey
{
    public int sceneId;

    public RoomKey ()
    {
    }

    public RoomKey (int sceneId)
    {
        this.sceneId = sceneId;
    }

    // from PlaceKey
    public String getPlaceType ()
    {
        return OrthRoomCodes.ROOM_PLACE_TYPE;
    }

    // from PlaceKey
    @Override protected int compareWithinType (PlaceKey other)
    {
        return Comparators.compare(sceneId, ((RoomKey) other).sceneId);
    }
}
