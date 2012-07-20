//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.nodelet.data;

import com.threerings.presents.net.BootstrapData;

/**
 * Data returned to the nodelet client when a new session is kicked off.
 */
public class NodeletBootstrapData extends BootstrapData
{
    /** The oid of the DObject corresponding to the one requested by the original Nodelet instance.
     * This is optional depending on the subsystem logic. For example, guild and party connections
     * normally only exist when there is a specific guild or party to connection to. */
    public int targetOid;
}
