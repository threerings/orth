//
// $Id$

package com.threerings.orth.ui {

/**
 * To be implemented by any {@link MediaDescs} that references its media by URL path.
 */
public interface PathMediaDesc
{
    /**
     * Returns the path of the URL that references this media.
     */
    function getMediaPath () :String;
}
}
