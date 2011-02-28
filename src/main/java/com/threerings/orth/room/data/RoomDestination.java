//
// $Id$

package com.threerings.orth.room.data;

import com.threerings.io.SimpleStreamableObject;

import com.threerings.orth.room.data.OrthLocation;
import com.threerings.orth.world.data.Destination;
import com.threerings.orth.world.data.PlaceKey;

public class RoomDestination extends SimpleStreamableObject
    implements Destination
{
    public RoomDestination ()
    {
    }

    public RoomDestination (RoomKey key)
    {
        this(key, null);
    }

    public RoomDestination (RoomKey key, OrthLocation location)
    {
        _key = key;
        _loc = location;
    }

    // from Destination
    public PlaceKey getPlaceKey ()
    {
        return _key;
    }

    /**
     * The location within the destination at which we should arrive; this can be null,
     * in which case we arrive in the default starting position.
     */
    public OrthLocation getLocation ()
    {
        return _loc;
    }

    protected RoomKey _key;
    protected OrthLocation _loc;
}
