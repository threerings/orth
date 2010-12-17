//
// $Id: $

package com.threerings.orth.data;

import com.threerings.util.Name;

import com.threerings.presents.net.Credentials;

/**
 * Contains extra information used during authentication with an orth server.
 */
public class OrthCredentials extends Credentials
{
    /** A session token that identifies a user without requiring username or password. */
    public String sessionToken;

    /**
     * Returns our username or null if none was provided.
     */
    public Name getUsername ()
    {
        return _username;
    }

    @Override // from Object
    public String toString ()
    {
        StringBuilder buf = new StringBuilder("[");
        toString(buf);
        return buf.append("]").toString();
    }

    protected void toString (StringBuilder buf)
    {
        buf.append(", token=").append(sessionToken);
        buf.append(", username=").append(_username);
    }

    protected Name _username;
}
