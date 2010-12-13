//
// $Id: $

package com.threerings.orth.entity.client {

import com.threerings.presents.dobj.DSet_Entry;

import com.threerings.util.Hashable;
import com.threerings.util.Comparable;

import com.threerings.orth.data.MediaDesc;
import com.threerings.orth.room.data.EntityIdent;

/**
 * Client-side information on an entity, i.e. anything that can appear in a room.
 */
public interface Entity
    extends Comparable, Hashable, DSet_Entry
{
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