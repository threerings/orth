//
// $Id: PartyCredentials.as 18101 2009-09-16 21:22:48Z ray $

package com.threerings.orth.party.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;
import com.threerings.util.Name;

import com.threerings.orth.data.OrthCredentials;

/**
 * Used to authenticate a party session.
 */
public class PartyCredentials extends OrthCredentials
{
    /** The party that the authenticating user wishes to join. */
    public var partyId :int;

    public function PartyCredentials (username :Name)
    {
        super(username);
    }

    // from interface Streamable
    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeInt(partyId);
    }
}
}
