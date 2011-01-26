//
// $Id: $

package com.threerings.orth.aether.data;

import com.threerings.presents.net.UsernamePasswordCreds;

/**
 * Contains information used during authentication of an orth aether session.
 */
public class AetherCredentials extends UsernamePasswordCreds
{
    /** The machine identifier of the client, if one is known. */
    public String ident;

    protected void toString (StringBuilder buf)
    {
        super.toString(buf);
        buf.append(", ident=").append(ident);
    }
}
