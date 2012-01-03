//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.room.data;

import com.threerings.crowd.data.OccupantInfo;

import com.threerings.orth.data.MediaDesc;

/**
 * Contains published information about an actor in a scene (members and pets).
 */
public abstract class ActorInfo extends OccupantInfo
{
    /**
     * Returns the media that is used to display this actor.
     */
    public MediaDesc getMedia ()
    {
        return _media;
    }

    /**
     * Returns the item identifier that is used to identify this actor.
     */
    public EntityIdent getEntityIdent ()
    {
        return _ident;
    }

    /**
     * Return the current state of the actor, which may be null.
     */
    public String getState ()
    {
        return _state;
    }

    /**
     * Updates the state of this actor. The actor must be republished to the room for the state
     * change to take effect.
     */
    public void setState (String state)
    {
        _state = state;
    }

    /**
     * Updates the media for this actor.
     */
    public abstract void updateMedia (ActorObject body);

    protected ActorInfo (ActorObject body)
    {
        super(body);
        _state = body.actorState;
        updateMedia(body);
    }

    /** Used when unserializing. */
    protected ActorInfo ()
    {
    }

    @Override // from SimpleStreamableObject
    protected void toString (StringBuilder buf)
    {
        super.toString(buf);
        buf.append(", media=").append(_media).append(", ident=").append(_ident);
        buf.append(", state=").append(_state);
    }

    protected MediaDesc _media;
    protected EntityIdent _ident;
    protected String _state;
}
