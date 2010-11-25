//
// $Id: MediaDesc.as 19417 2010-10-20 20:52:22Z zell $

package com.threerings.orth.data {

/**
 * A class containing metadata about a media object.
 */
public interface MediaDesc
{
    /**
     * Returns the path of the URL that references this media.
     */
    function getMediaPath () :String;

    /**
     * Returns the mime type of this media.
     */
    function getMimeType () :int;

    /** The size constraint on this media, if any. See {@link #computeConstraint}. */
    function get constraint () :int;

    /** The MIME type of the media associated with this item. */
    function get mimeType () :int;

    /**
     * Is this media purely audio?
     */
    function isAudio () :Boolean;

    /**
     * Is this media merely an image type?
     */
    function isImage () :Boolean;

    /**
     * Is this media a SWF?
     */
    function isSWF () :Boolean;

    /**
     * Is this media video?
     */
    function isVideo () :Boolean;

    function isExternal () :Boolean;

    /**
     * Get some identifier that can be used to refer to this media across
     * sessions (used as a key in prefs).
     */
    /* abstract */ function getMediaId () :String;

    // from MediaDesc
    function isBleepable () :Boolean;

    /**
     * Is this a zip of some sort?
     */
    function isRemixed () :Boolean;

    /**
     * Is this media remixable?
     */
    function isRemixable () :Boolean;

    /**
     * Return true if this media has a visual component that can be shown
     * in flash.
     */
    function hasFlashVisual () :Boolean;
}
}
