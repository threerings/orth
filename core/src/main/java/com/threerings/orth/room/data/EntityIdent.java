//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.room.data;

import com.threerings.io.Streamable;

import com.threerings.util.ActionScript;

/**
 * A fully qualified entity identifier (type and integer id).
 */
@ActionScript(omit=true)
public interface EntityIdent
    extends Streamable, Comparable<EntityIdent>
{
    /**
     * Return the {@link EntityType} of this entity.
     */
    EntityType<?> getType ();

    /**
     * Return the numerical identifier of this entity, unique within its {@link #getType}.
     */
    int getId();
}
