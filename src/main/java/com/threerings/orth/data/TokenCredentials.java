//
//

package com.threerings.orth.data;

import com.threerings.presents.net.Credentials;

/**
 * Contains extra information used during authentication with an orth server.
 */
public class TokenCredentials extends Credentials
{
    /** A session token that identifies a user without requiring username or password. */
    public String sessionToken;

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
    }
}