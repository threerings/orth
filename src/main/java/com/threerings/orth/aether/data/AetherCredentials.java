//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.aether.data;

import com.samskivert.util.StringUtil;
import com.threerings.presents.net.Credentials;

/**
 * Contains information used during authentication of an orth aether session.
 */
public abstract class AetherCredentials extends Credentials
    implements Credentials.HasMachineIdent
{
    /** The machine identifier of the client, if one is known. */
    public String ident;

    /** The name for these credentials. The exact meaning of the name is determined by type. */
    public String name;

    @Override public String getMachineIdent ()
    {
        return ident;
    }

    @Override public String toString ()
    {
        return getClass().getSimpleName() + " " + StringUtil.fieldsToString(this);
    }
}
