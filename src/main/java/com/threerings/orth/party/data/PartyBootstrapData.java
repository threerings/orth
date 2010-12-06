//
// $Id: PartyBootstrapData.java 14290 2009-01-08 22:00:42Z mdb $

package com.threerings.orth.party.data;

import com.threerings.presents.net.BootstrapData;

/**
 * Bootstrap data provided to a party client connection.
 */
public class PartyBootstrapData extends BootstrapData
{
    /** The oid of the client's party object. */
    public int partyOid;
}
