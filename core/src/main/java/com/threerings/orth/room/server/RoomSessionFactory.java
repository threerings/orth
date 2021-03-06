//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.room.server;

import com.google.inject.Inject;
import com.google.inject.Injector;
import com.google.inject.Singleton;

import com.threerings.util.Name;

import com.threerings.presents.net.AuthRequest;
import com.threerings.presents.server.ClientResolver;
import com.threerings.presents.server.PresentsSession;
import com.threerings.presents.server.SessionFactory;

import com.threerings.orth.room.data.RoomAuthName;
import com.threerings.orth.room.data.RoomCredentials;

@Singleton
public class RoomSessionFactory extends SessionFactory
{
    @Override
    public Class<? extends PresentsSession> getSessionClass (AuthRequest areq)
    {
        if (areq.getCredentials().getClass().equals(RoomCredentials.class)) {
            return RoomSession.class;
        }
        return null;
    }

    @Override
    public Class<? extends ClientResolver> getClientResolverClass (Name username)
    {
        if (username.getClass().equals(RoomAuthName.class)) {
            return RoomClientResolver.class;
        }
        return null;
    }

    @Inject protected Injector _injector;
}
