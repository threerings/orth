//
// $Id: $

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
