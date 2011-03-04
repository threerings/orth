//
// $Id$

package com.threerings.orth.ui {

import flash.display.DisplayObject;

import com.threerings.orth.data.MediaDesc;

/**
 * To be implemented by any {@link MediaDescs} that supplies a fully instantiated 
 * {@link DisplayObject}.
 */
public interface ObjectMediaDesc extends MediaDesc
{
    /**
     * Returns the path of the URL that references this media.
     */
    function getMediaObject () :DisplayObject;
}
}
