//
// $Id$

package com.threerings.orth.room.data;

import com.threerings.orth.world.data.OrthPlace;
import com.threerings.whirled.data.ScenePlace;

public class RoomPlace extends ScenePlace
    implements OrthPlace
{
    /** The peer this room is hosted on. */
    public String peer;

    /** The name of this room. */
    public String name;

    // from OrthPlace
    public String getPeer ()
    {
        return peer;
    }

    // from OrthPlace
    public String describePlace ()
    {
        return name;
    }

    @Override
    public String toString ()
    {
        return "Room<" + name + ", " + peer + ", " + sceneId + ">";
    }

    @Override
    public int hashCode ()
    {
        return sceneId;
    }

    @Override
    public boolean equals (Object other)
    {
        return (other instanceof RoomPlace) && ((RoomPlace) other).peer.equals(peer) &&
            ((RoomPlace) other).sceneId == sceneId;
    }
}
