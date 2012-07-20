//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.party.data;

import com.threerings.orth.nodelet.data.Nodelet;

public class PartyNodelet extends Nodelet
{
    public int partyId;

    public PartyNodelet (int partyId)
    {
        this.partyId = partyId;
    }

    @Override
    public Comparable<?> getKey ()
    {
        return partyId;
    }
}
