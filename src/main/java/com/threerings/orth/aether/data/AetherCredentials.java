//
// $Id: $

package com.threerings.orth.aether.data;

import com.threerings.orth.data.OrthCredentials;

/**
 * Contains information used during authentication of an orth aether session.
 */
public class AetherCredentials extends OrthCredentials
{
    /** The machine identifier of the client, if one is known. */
    public String ident;

    /**
     * Returns our encrypted password data, or null if none was provided.
     */
    public String getPassword ()
    {
        return _password;
    }

    protected void toString (StringBuilder buf)
    {
        super.toString(buf);
        buf.append(", password=").append(_password);
        buf.append(", ident=").append(ident);
    }

    protected String _password;
}
