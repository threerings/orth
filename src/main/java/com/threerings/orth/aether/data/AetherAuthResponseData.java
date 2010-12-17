//
// $Id: MsoyAuthResponseData.java 8844 2008-04-15 17:05:43Z nathan $

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
