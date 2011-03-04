//
// $Id: MediaDesc.as 19417 2010-10-20 20:52:22Z zell $

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

    /**
     * Returns the constraint on this media, if any.
     */
    function getConstraint () :int;
}
}
