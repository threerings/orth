//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.nodelet.data;

import com.threerings.orth.data.TokenCredentials;

/**
 * Credentials for logging into a nodelet server. When the server receives a nodelet credentials
 * from a login attempt, the class of the {@link #nodelet} will be used to determine which
 * {@link NodeletRegistry} to use in managing the connection.
 * <p>Note that locus systems manage their own authentication and so do not use this.</p>
 */
public class NodeletCredentials extends TokenCredentials
{
    /** The nodelet that the client is attempting to access. */
    public Nodelet nodelet;

    @Override
    protected void toString (StringBuilder buf)
    {
        super.toString(buf);
        if (nodelet != null) {
            buf.append(", nodelet=").append(nodelet);
        }
    }
}
