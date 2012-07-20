//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.entity.data {

/**
 * Client-side information about an entity that can represent a player (or perhaps an NPC).
 */
public interface Pet
    extends Entity
{
    function get name () :String;
}
}
