//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.entity.data {
import com.threerings.util.Comparable;
import com.threerings.util.Hashable;

import com.threerings.presents.dobj.DSet_Entry;

import com.threerings.orth.data.MediaDesc;
import com.threerings.orth.room.data.EntityIdent;

/**
 * Client-side information on an entity, i.e. anything that can appear in a room.
 */
public interface Entity
    extends Comparable, Hashable, DSet_Entry
{
    /**
     * The human-readable name of this entity.
     */
    function getName () :String;

    /**
     * Returns this entity's composite identifier.
     */
    function getIdent () :EntityIdent;

    /**
     * Returns a media descriptor for the media that should be used to display our thumbnail
     * representation.
     */
    function getThumbnailMedia () :MediaDesc;

    /**
     * Returns a media descriptor for the media that should be used to display our furniture
     * representation.
     */
    function getFurniMedia () :MediaDesc;
}
}
