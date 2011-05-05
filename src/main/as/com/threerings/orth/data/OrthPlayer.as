//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.data {

import com.threerings.presents.dobj.DObject;

import com.threerings.orth.aether.data.PlayerName;

/**
 * Implemented by any client object that represents an Orth player.
 */
public interface OrthPlayer
{
    /** Return our implementing object as a {@link DObject}. */
    function self () :DObject;

    /** Our {@link PlayerName}, which may not be the same for different classes, but whose
        numerical ID should always be identical for a given player. */
    function getPlayerName () :PlayerName;
}
}
