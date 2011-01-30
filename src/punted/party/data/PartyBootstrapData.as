//
// $Id: PartyBootstrapData.as 14328 2009-01-10 18:45:51Z mdb $

package com.threerings.orth.party.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

import com.threerings.presents.net.BootstrapData;

/**
 * Bootstrap data provided to a party client connection.
 */
public class PartyBootstrapData extends BootstrapData
{
    /** The oid of the client's party object. */
    public var partyOid :int;

    // documentation inherited
    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        partyOid = ins.readInt();
    }

    // from interface Streamable
    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeInt(partyOid);
    }
}
}
