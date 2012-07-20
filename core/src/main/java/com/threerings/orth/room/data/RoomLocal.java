//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.room.data;

import com.threerings.crowd.data.OccupantInfo;

/**
 * Provides a way for the {@link MemberObject} and {@link PetObject} to obtain information from the
 * RoomManager when configuring their {@link OccupantInfo}.
 */
public interface RoomLocal
{
    /** Whether or not we're a manager of this room. */
    public boolean isManager (ActorObject body);
}
