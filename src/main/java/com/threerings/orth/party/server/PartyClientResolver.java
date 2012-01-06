//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.party.server;

import com.threerings.presents.data.ClientObject;
import com.threerings.presents.server.ClientResolver;

import com.threerings.orth.data.PlayerName;
import com.threerings.orth.party.data.PartierObject;
import com.threerings.orth.party.data.PartyAuthName;

/**
 * Handles the resolution of partier client information.
 */
public class PartyClientResolver extends ClientResolver
{
    @Override // from PresentsClientResolver
    public ClientObject createClientObject ()
    {
        return new PartierObject();
    }

    @Override // from PresentsSession
    protected void resolveClientData (ClientObject clobj)
        throws Exception
    {
        super.resolveClientData(clobj);

        PartierObject partObj = (PartierObject)clobj;
        PartyAuthName authName = (PartyAuthName)_username;

        partObj.playerName = new PlayerName(authName.toString(), authName.getId());
    }
}
