//
// $Id: OrthCredentials.as 19187 2010-05-24 14:26:26Z zell $

package com.threerings.orth.data {

import com.threerings.util.Joiner;
import com.threerings.util.Name;

import com.threerings.presents.net.Credentials;

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

/**
 * Contains information needed to authenticate with an Orth server.
 */
public class OrthCredentials extends Credentials
{
    /** A session token that identifies a user without requiring username or password. */
    public var sessionToken :String;

    /**
     * Creates credentials with the specified username.
     */
    public function OrthCredentials (username :Name)
    {
        _username = username;
    }

    public function getUsername () :Name
    {
        return _username;
    }

    // from interface Streamable
    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeField(sessionToken);
        out.writeObject(_username);
    }

    override protected function toStringJoiner (j :Joiner) :void
    {
        super.toStringJoiner(j);
        j.add("username", _username);
    }

    protected var _username :Name;
}
}
