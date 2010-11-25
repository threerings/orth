package com.threerings.orth.scene.data {

import com.threerings.orth.scene.data.EntityMedia;

public interface EntityData
{
    function getEntityIdent () :EntityIdent;
    
    /**
     * Returns a media descriptor for the media that should be used to display our furniture
     * representation.
     */
    function getFurniMedia () :EntityMedia;

    /**
     * Returns our raw furniture media which may be null. Don't call this method.
     */
    function getRawFurniMedia () :EntityMedia;
}
}
