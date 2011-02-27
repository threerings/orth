//
// $Id: $

package com.threerings.orth.data {

public interface ClientMediaDesc extends MediaDesc
{
    /**
     * Returns the path of the URL that references this media.
     */
    function getMediaPath () :String;
}
}
