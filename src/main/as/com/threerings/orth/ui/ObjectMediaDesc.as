//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

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
     * Returns the actual {@link DisplayObject} instance referenced by this descriptor.
     */
    function getMediaObject () :DisplayObject;
}
}
