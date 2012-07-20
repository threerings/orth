//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.data;

import com.threerings.util.ActionScript;

import com.threerings.presents.data.AuthCodes;

/**
 * Additional authorization codes for Orth.
 */
@ActionScript(omit=true)
public interface OrthAuthCodes extends AuthCodes
{
    /** A code indicating that the client version is out of date. */
    public static final String VERSION_MISMATCH = "m.version_mismatch";

    /** A code indicating that the client has a newer version of the code
     * than the server which generally means we're in the middle of updating the game. */
    public static final String NEWER_VERSION = "m.newer_version";

    /** A code indicating that a client's session has expired. */
    public static final String SESSION_EXPIRED = "m.session_expired";
}
