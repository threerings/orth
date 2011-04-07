//
// $Id$

package com.threerings.orth.data;

import com.threerings.presents.net.Credentials;

/**
 * Contains a sessionToken for secondary processes to authenticate with against an Orth server.
 */
public class TokenCredentials extends Credentials
{
    /** A session token that identifies a user without requiring username or password. */
    public String sessionToken;

    /** An optional subsystem id that can be used to differentiate different kinds of token
     * based authentications without a proliferation of subclasses. */
    public String subsystemId;

    /** An optional reference to a server object id. This is for use by orth subsystems as they see
     * fit. If zero, the subsystem does not use it. */
    public int objectId;

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
        if (objectId != 0) {
            buf.append(", objectId=").append(objectId);
        }
    }
}
