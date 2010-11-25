package com.threerings.orth.room.data {

import com.threerings.orth.data.MediaDesc;
public interface EntityData
{
    function getEntityIdent () :EntityIdent;

    /**
     * Returns a media descriptor for the media that should be used to display our furniture
     * representation.
     */
    function getFurniMedia () :MediaDesc;

    /**
     * Returns our raw furniture media which may be null. Don't call this method.
     */
    function getRawFurniMedia () :MediaDesc;
}
}
