//
// $Id: $


package com.threerings.orth.entity.data;

import com.threerings.io.SimpleStreamableObject;

import com.threerings.orth.data.MediaDesc;
import com.threerings.orth.room.data.EntityIdent;

/**
 * A basic streamable implementation of {@link Entity}.
 */
public class EntityObject extends SimpleStreamableObject
    implements Entity
{
    public MediaDesc media;
    public EntityIdent ident;

    // from DSet.Entry
    public Comparable<?> getKey ()
    {
        return getIdent();
    }

    // from Comparable
    public int compareTo (Entity other) {
        return ident.compareTo(other.getIdent());
    }

    // from Entity
    public MediaDesc getFurniMedia () {
        return media;
    }

    // from Entity
    public MediaDesc getThumbnailMedia () {
        // ORTH TODO: not at all sure we need this
        return null;
    }

    // from Entity
    public EntityIdent getIdent () {
        return ident;
    }
}
