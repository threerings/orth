//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.aether.data;

import com.threerings.presents.net.UsernamePasswordCreds;

/**
 * Contains information used during authentication of an orth aether session.
 */
public class AetherCredentials extends UsernamePasswordCreds
{
    /** The machine identifier of the client, if one is known. */
    public String ident;

    @Override
    protected void toString (StringBuilder buf)
    {
        super.toString(buf);
        buf.append(", ident=").append(ident);
    }
}
