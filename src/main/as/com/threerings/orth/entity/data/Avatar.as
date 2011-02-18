//
// $Id: $

package com.threerings.orth.entity.data {

import com.threerings.orth.data.MediaDesc;

/**
 * Client-side information about an entity that can represent a player (or perhaps an NPC).
 */
public interface Avatar
    extends Entity
{
    /**
     * Returns a media descriptor for the media that implements our actual avatar.
     */
    function getAvatarMedia () :MediaDesc;

    /**
     * Return the scaling to apply to the avatar media.
     */
    function getScale () :Number;
}
}
