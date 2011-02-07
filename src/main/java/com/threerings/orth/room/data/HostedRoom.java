//
// $Id: $


package com.threerings.orth.room.data;

import com.threerings.util.ActionScript;

import com.threerings.orth.peer.data.HostedPlace;

/**
 *
 */
@ActionScript(omit=true)
public class HostedRoom extends HostedPlace
{
    public HostedRoom ()
    {
    }

    public HostedRoom (RoomKey key, String name)
    {
        super(key, name);
    }

    public RoomKey getRoomKey ()
    {
        return (RoomKey) key;
    }
}
