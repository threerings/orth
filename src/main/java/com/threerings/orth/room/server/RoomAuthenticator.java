//
// $Id$

package com.threerings.orth.room.server;

import com.google.inject.Inject;

import com.threerings.presents.net.AuthResponse;
import com.threerings.presents.net.AuthResponseData;

import com.threerings.presents.server.ChainedAuthenticator;

import com.threerings.presents.server.net.AuthingConnection;

import com.threerings.orth.data.OrthAuthCodes;

import com.threerings.orth.room.data.RoomCredentials;
import com.threerings.orth.room.data.RoomAuthName;
import com.threerings.orth.room.persist.server.OrthPlayerRepository;

public class RoomAuthenticator extends ChainedAuthenticator
{
    @Override
    protected void processAuthentication (AuthingConnection conn, AuthResponse rsp)
        throws AuthException
    {
        RoomCredentials creds = (RoomCredentials)conn.getAuthRequest().getCredentials();
        int playerId = _playerRepo.loadPlayerIdForSession(creds.sessionToken);
        if (playerId == -1) {
            throw new AuthException(OrthAuthCodes.SESSION_EXPIRED);
        }
        conn.setAuthName(new RoomAuthName(creds.displayName, playerId));
        rsp.getData().code = AuthResponseData.SUCCESS;
    }

    @Override
    public boolean shouldHandleConnection (AuthingConnection conn)
    {
        return conn.getAuthRequest().getCredentials() instanceof RoomCredentials;
    }

    @Inject protected OrthPlayerRepository _playerRepo;
}
