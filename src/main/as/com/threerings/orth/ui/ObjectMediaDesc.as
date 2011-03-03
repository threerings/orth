//
// $Id$

package com.threerings.orth.ui {

import flash.display.DisplayObject;

/**
 * To be implemented by any {@link MediaDescs} that supplies a fully instantiated 
 * {@link DisplayObject}.
 */
public interface ObjectMediaDesc
{
    /**
     * Returns the path of the URL that references this media.
     */
    function getMediaObject () :DisplayObject;
}
}
