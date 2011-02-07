//
// $Id$

package com.threerings.orth.room.data;

import com.threerings.orth.world.data.PlaceKey;

public class RoomKey
    implements PlaceKey
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
    public OrthPlace toPlace (String hostingPeer, int[] hostingPorts)
    {
        RoomPlace place = new RoomPlace();
        place.peer = hostingPeer;
        place.ports = hostingPorts;

        // ORTH TODO: this toPlace() business may not be the best idea; are we really
        // supposed to have enough information available in this data object? Why would we?
        place.name = "???";
        
    }

    // from PlaceKey
    public String getPlaceType ()
    {
        return OrthSceneCodes.ROOM_PLACE_TYPE;
    }
}
