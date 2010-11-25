//
// $Id: $

package com.threerings.orth.room.data;

import com.samskivert.util.ByteEnum;
import com.threerings.io.Streamable;

/**
 * A fully qualified entity identifier (type and integer id).
 */
public interface EntityIdent
    extends Streamable, Comparable<EntityIdent>
{
    /** An opaque entity type which each project should implement as a {@link ByteEnum}. */
    public interface EntityType<T extends Enum<T> & EntityType<T>>
        extends ByteEnum, Streamable, Comparable<T>
    {
    }

    /**
     * Return the {@link EntityType} of this entity.
     */
    EntityType<?> getType ();

    /**
     * Return the numerical identifier of this entity, unique within its {@link #getType}.
     */
    int getId();
}
