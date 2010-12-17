// GENERATED PREAMBLE START
//
// $Id$

package com.threerings.orth.aether.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;
import com.threerings.orth.data.OrthCredentials;
// GENERATED PREAMBLE END

/**
 * Used to authenticate a aether session.
 */
// GENERATED CLASSDECL START
public class AetherCredentials extends OrthCredentials
{
// GENERATED CLASSDECL END
// GENERATED STREAMING START
    public var ident :String;

    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        ident = ins.readField(String);
        _password = ins.readField(String);
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeField(ident);
        out.writeField(_password);
    }

    protected var _password :String;
// GENERATED STREAMING END

    /**
     * Creates credentials with the specified username and password. The other public fields should
     * be set before logging in.
     */
    public function AetherCredentials (username :Name, password :String = null)
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

    protected var _password :String;
// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END
