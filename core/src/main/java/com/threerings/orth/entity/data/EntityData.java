//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.entity.data;

import com.threerings.io.SimpleStreamableObject;

import com.threerings.orth.data.MediaDesc;
import com.threerings.orth.room.data.EntityIdent;

/**
 * A basic streamable implementation of {@link Entity}.
 */
public class EntityData extends SimpleStreamableObject
    implements Entity
{
    public String name;
    public MediaDesc media;
    public EntityIdent ident;

    public EntityData (String name, MediaDesc media, EntityIdent ident)
    {
        this.name = name;
        this.media = media;
        this.ident = ident;
    }

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
    public String getName () {
        return name;
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
