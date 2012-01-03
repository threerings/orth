//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.data {

import com.threerings.util.Equalable;

/**
 * A class containing metadata about a media object.
 */
public interface MediaDesc
    extends Equalable
{
    /**
     * Returns the mime type of this media.
     */
    function getMimeType () :int;
}
}
