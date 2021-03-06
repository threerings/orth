//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.ui {
import flash.display.Sprite;

import com.threerings.orth.data.MediaDesc;
import com.threerings.orth.data.MediaDescSize;

/**
 * Wraps a MediaContainer into a Sprite
 */
public class MediaWrapper
{
    /**
     * Factory to create a MediaWrapper configured to view media represented by a MediaDesc
     * at the specified size.
     *
     * ORTH TODO: MediaWrapper has little remaining purpose without Flex, but for now we
     * keep this static function which helpfully creates a scaling container.
     */
    public static function createView (
        desc :MediaDesc, size :int = MediaDescSize.THUMBNAIL_SIZE) :Sprite
    {
        return  ScalingMediaDescContainer.createView(desc, size);
    }
}
}
