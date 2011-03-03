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

    /** The size constraint on this media, if any. See {@link #computeConstraint}. */
    // ORTH TODO - nuke this
    function get constraint () :int;

    /** The MIME type of the media associated with this item. */
    // ORTH TODO - nuke this
    function get mimeType () :int;

    /**
     * Is this media merely an image type?
     */
    function isImage () :Boolean;

    /**
     * Is this media a SWF?
     */
    function isSWF () :Boolean;

    /**
     * Is this media purely audio?
     */
    function isAudio () :Boolean;

    /**
     * Is this media video?
     */
    function isVideo () :Boolean;

    /**
     * Return true if this media has a visual component that can be shown
     * in flash.
     */
    function hasFlashVisual () :Boolean;
}
}
