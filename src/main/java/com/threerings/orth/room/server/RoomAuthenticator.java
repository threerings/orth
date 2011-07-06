//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.room.server;

import com.google.inject.Inject;

import com.threerings.presents.net.AuthResponse;
import com.threerings.presents.net.AuthResponseData;
import com.threerings.presents.server.ChainedAuthenticator;
import com.threerings.presents.server.net.AuthingConnection;

import com.threerings.orth.data.OrthAuthCodes;
import com.threerings.orth.data.PlayerName;
import com.threerings.orth.room.data.RoomAuthName;
import com.threerings.orth.room.data.RoomCredentials;
import com.threerings.orth.server.persist.PlayerRecord;
import com.threerings.orth.server.persist.PlayerRepository;

public class RoomAuthenticator extends ChainedAuthenticator
{
    @Override
    protected void processAuthentication (AuthingConnection conn, AuthResponse rsp)
        throws AuthException
    {
        RoomCredentials creds = (RoomCredentials)conn.getAuthRequest().getCredentials();
        PlayerRecord player = _playerRepo.loadPlayerForSession(creds.sessionToken);
        if (player == null) {
            throw new AuthException(OrthAuthCodes.SESSION_EXPIRED);
        }
        PlayerName name = player.getName();
        conn.setAuthName(new RoomAuthName(name.toString(), name.getId()));
        rsp.getData().code = AuthResponseData.SUCCESS;
    }

    @Override
    public boolean shouldHandleConnection (AuthingConnection conn)
    {
        return conn.getAuthRequest().getCredentials() instanceof RoomCredentials;
    }

    @Inject protected PlayerRepository _playerRepo;
}
