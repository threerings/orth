//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.entity.data;

import com.threerings.orth.data.MediaDesc;

/**
 * Client-side information about an entity that can represent a player (or perhaps an NPC).
 */
public interface Pet
    extends Entity
{
    /**
     * Returns a media descriptor for the media that implements our pet.
     */
    MediaDesc getPetMedia ();

    /**
     * Return the scaling to apply to the pet media.
     */
    float getScale ();
}
