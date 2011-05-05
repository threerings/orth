//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.locus.client {

public interface BootablePlaceController
{
    /**
     * Can the local user boot people from this place?
     */
    function canBoot () :Boolean;

    function bootPlayer (playerId :int) :void;
}
}
