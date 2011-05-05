//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.entity.data;

import com.threerings.presents.dobj.DSet;

import com.threerings.orth.data.MediaDesc;
import com.threerings.orth.room.data.EntityIdent;

/**
 * Client-side information on an entity, i.e. anything that can appear in a room.
 */
public interface Entity
    extends Comparable<Entity>, DSet.Entry
{
    /**
     * The human-readable name of this entity.
     */
    String getName ();

    /**
     * Returns this entity's composite identifier.
     */
    EntityIdent getIdent ();

    /**
     * Returns a media descriptor for the media that should be used to display our thumbnail
     * representation.
     */
    MediaDesc getThumbnailMedia ();

    /**
     * Returns a media descriptor for the media that should be used to display our furniture
     * representation.
     */
    MediaDesc getFurniMedia ();
}
