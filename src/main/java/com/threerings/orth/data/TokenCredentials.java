//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.data;

import com.threerings.presents.net.Credentials;

/**
 * Contains a sessionToken for secondary processes to authenticate with against an Orth server.
 */
public class TokenCredentials extends Credentials
{
    /** A session token that identifies a user without requiring username or password. */
    public String sessionToken;

    @Override // from Object
    public String toString ()
    {
        StringBuilder buf = new StringBuilder(getClass().getSimpleName()).append(" [");
        toString(buf);
        return buf.append("]").toString();
    }

    protected void toString (StringBuilder buf)
    {
        buf.append(", token=").append(sessionToken);
    }
}
