//
// $Id: PartyClientResolver.java 19629 2010-11-24 16:40:04Z zell $

package com.threerings.orth.party.server;

import com.threerings.presents.data.ClientObject;
import com.threerings.presents.server.ClientResolver;

import com.threerings.orth.aether.data.VizPlayerName;
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

        // TODO(bruno): Pull name and photo from a DB.

        partObj.playerName = new VizPlayerName(authName.toString(), authName.getId(), null);
    }
}
