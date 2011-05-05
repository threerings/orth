//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.
package com.threerings.orth.room.client {

import com.threerings.whirled.client.PendingData;

import com.threerings.orth.room.data.OrthLocation;

/**
 * Extends our pending scene data with Orth specific bits.
 */
public class OrthPendingData extends PendingData
{
    /** The location in the new scene at which we want to arrive. */
    public var destLoc :OrthLocation;
}
}
