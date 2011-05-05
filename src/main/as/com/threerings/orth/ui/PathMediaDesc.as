//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.
package com.threerings.orth.ui {

import com.threerings.orth.data.MediaDesc;

/**
 * To be implemented by any {@link MediaDescs} that references its media by URL path.
 */
public interface PathMediaDesc extends MediaDesc
{
    /**
     * Returns the path of the URL that references this media.
     */
    function getMediaPath () :String;
}
}
