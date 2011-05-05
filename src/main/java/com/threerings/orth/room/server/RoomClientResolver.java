//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.
package com.threerings.orth.room.server;

import com.threerings.crowd.server.CrowdClientResolver;

import com.threerings.presents.data.ClientObject;
import com.threerings.presents.server.ClientLocal;

import com.threerings.orth.aether.data.PlayerName;
import com.threerings.orth.data.AuthName;
import com.threerings.orth.room.data.SocializerObject;

/**
 * Used to configure room-specific client object data.
 */
public class RoomClientResolver extends CrowdClientResolver
{
    @Override
    public ClientObject createClientObject ()
    {
        return new SocializerObject();
    }

    @Override
    public ClientLocal createLocalAttribute ()
    {
        return new ActorLocal();
    }

    @Override // from ClientResolver
    protected void resolveClientData (final ClientObject clobj)
        throws Exception
    {
        super.resolveClientData(clobj);

        SocializerObject sobj = (SocializerObject) clobj;
        populate(sobj);
    }

    protected void populate (SocializerObject sobj)
    {
        AuthName name = (AuthName) sobj.username;
        sobj.name = new PlayerName(name.toString(), name.getId());
    }
}
