//
// $Id: WorldCredentials.as 18101 2009-09-16 21:22:48Z ray $

package com.threerings.orth.world.data {
import com.threerings.orth.data.OrthCredentials;
import com.threerings.util.Joiner;
import com.threerings.util.Name;

import com.threerings.io.ObjectOutputStream;

/**
 * Used to authenticate a world session.
 */
public class WorldCredentials extends OrthCredentials
{
    /** The machine identifier of the client, if one is known. */
    public var ident :String;

    /**
     * Creates credentials with the specified username and password. The other public fields should
     * be set before logging in.
     */
    public function WorldCredentials (username :Name, password :String)
    {
        super(username);
        _password = password;
    }

    // from interface Streamable
    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeField(ident);
        out.writeField(_password);
    }

    // documentation inherited
    override protected function toStringJoiner (j :Joiner) :void
    {
        super.toStringJoiner(j);
        j.add("password", _password);
    }

    /** Our encrypted password, if one was provided. */
    protected var _password :String;
}
}
