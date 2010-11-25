package com.threerings.orth.room.server;

import com.threerings.crowd.server.BodyLocal;
import com.threerings.orth.room.data.ActorObject;
import com.threerings.orth.room.data.EntityIdent;
import com.threerings.orth.room.data.EntityMemories;
import com.threerings.orth.room.data.OrthSceneObject;

public class ActorLocal extends BodyLocal
{
    /** The memories of the actor entity. */
    public EntityMemories memories;

    public ActorLocal ()
    {
        super();
    }

    /**
     * Called when a player has just switched from one avatar to a new one or by {@link
     * #willEnterRoom} below. In either case, {@link #memories} is expected to contain the memories
     * for the avatar; either because it was put there (and possibly serialized in the case of a
     * peer move) when the player left a previous room, or because we put them there manually as
     * part of avatar resolution (see {@link MemberManager#finishSetAvatar}).
     */
    public void putAvatarMemoriesIntoRoom (OrthSceneObject roomObj)
    {
        if (memories != null) {
            roomObj.putMemories(memories);
            memories = null;
        }
    }

    /**
     * Called when we depart a room to remove our avatar memories from the room and store them in
     * this local storage.
     */
    public void takeAvatarMemoriesFromRoom (ActorObject actor, OrthSceneObject roomObj)
    {
        final EntityIdent avId = actor.getEntityIdent();
        memories = (avId != null) ? roomObj.takeMemories(avId) : null;
    }

    /**
     * Called by the {@link RoomManager} when we're about to enter a room, and also
     * takes care of calling willEnterPartyPlace().
     */
    public void willEnterRoom (ActorObject memobj, OrthSceneObject roomObj)
    {
        putAvatarMemoriesIntoRoom(roomObj);
    }

    /**
     * Called by the {@link RoomManager} when we're about to leave a room, and also
     * takes care of calling willLeavePartyPlace().
     */
    public void willLeaveRoom (ActorObject memobj, OrthSceneObject roomObj)
    {
        // remove our avatar memories from this room
        takeAvatarMemoriesFromRoom(memobj, roomObj);
    }

}
