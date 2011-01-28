//
// $Id: RoomLocal.java 13697 2008-12-05 21:07:52Z mdb $

package com.threerings.orth.room.data;

/**
 * Provides a way for the {@link MemberObject} and {@link PetObject} to obtain information from the
 * RoomManager when configuring their {@link OccupantInfo}.
 */
public interface RoomLocal
{
    /** Whether or not we're a manager of this room. */
    public boolean isManager (ActorObject body);
}
