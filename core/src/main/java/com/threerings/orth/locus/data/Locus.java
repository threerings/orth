//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.locus.data;

import com.threerings.io.Streamable;

import com.threerings.util.Equalable;

/**
 * The base type for a specification of a place, used both to instruct the Orth system to
 * host/instantiate the place.
 */
public interface Locus extends Streamable, Equalable
{
}
