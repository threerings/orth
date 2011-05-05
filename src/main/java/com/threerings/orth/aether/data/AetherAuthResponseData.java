//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.
package com.threerings.orth.aether.data;

import com.threerings.presents.net.AuthResponseData;

/**
 * Extends the normal auth response data with Orth-specific bits.
 */
public class AetherAuthResponseData extends AuthResponseData
{
    /** The session token assigned to this user, or null. */
    public String sessionToken;

    /** A machine identifier to be assigned to this machine, or null. */
    public String ident;

    /** A possible warning message to the user, or null. */
    public String warning;
}
