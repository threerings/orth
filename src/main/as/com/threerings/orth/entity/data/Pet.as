//
// $Id: $

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
