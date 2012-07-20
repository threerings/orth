//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.room.server;

import com.threerings.crowd.server.BodyLocal;

import com.threerings.orth.room.data.ActorObject;
import com.threerings.orth.room.data.EntityIdent;
import com.threerings.orth.room.data.EntityMemories;
import com.threerings.orth.room.data.OrthRoomObject;

public class ActorLocal extends BodyLocal
{
    /** The memories of the actor entity. */
    public EntityMemories memories;

    public ActorLocal ()
    {
        super();
    }

    /**
     * Called when we depart a room to remove our avatar memories from the room and store them in
     * this local storage.
     */
    public void takeAvatarMemoriesFromRoom (ActorObject actor, OrthRoomObject roomObj)
    {
        final EntityIdent avId = actor.getEntityIdent();
        memories = (avId != null) ? roomObj.takeMemories(avId) : null;
    }

    /**
     * Called by the {@link OrthRoomManager} when we're about to enter a room.
     */
    public void willEnterRoom (ActorObject memobj, OrthRoomObject roomObj)
    {
        if (memories != null) {
            roomObj.putMemories(memories);
            memories = null;
        }
    }

    /**
     * Called by the {@link OrthRoomManager} when we're about to leave a room.
     */
    public void willLeaveRoom (ActorObject memobj, OrthRoomObject roomObj)
    {
        // remove our avatar memories from this room
        takeAvatarMemoriesFromRoom(memobj, roomObj);
    }
}
