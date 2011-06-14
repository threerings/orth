//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.party.server;

import com.google.inject.Inject;
import com.google.inject.Singleton;
import com.threerings.presents.net.AuthResponse;
import com.threerings.presents.net.AuthResponseData;

import com.threerings.presents.server.ChainedAuthenticator;
import com.threerings.presents.server.net.AuthingConnection;

import com.threerings.orth.aether.data.PlayerName;
import com.threerings.orth.data.OrthAuthCodes;
import com.threerings.orth.party.data.PartyAuthName;
import com.threerings.orth.party.data.PartyCredentials;

import com.threerings.orth.server.persist.OrthPlayerRecord;
import com.threerings.orth.server.persist.OrthPlayerRepository;

/**
 * Handles partier authentication.
 */
@Singleton
public class PartyAuthenticator extends ChainedAuthenticator
{
    // fiddling to work around a circular dependency
    public void init (PartyRegistry partyReg)
    {
        _partyReg = partyReg;
    }

    @Override
    public boolean shouldHandleConnection (AuthingConnection conn)
    {
        return conn.getAuthRequest().getCredentials() instanceof PartyCredentials;
    }

    @Override
    protected void processAuthentication (AuthingConnection conn, AuthResponse rsp)
        throws AuthException
    {
        PartyCredentials creds = (PartyCredentials)conn.getAuthRequest().getCredentials();
        OrthPlayerRecord player = _playerRepo.loadPlayerForSession(creds.sessionToken);
        if (player == null) {
            throw new AuthException(OrthAuthCodes.SESSION_EXPIRED);
        }
        PlayerName name = player.getPlayerName();
        conn.setAuthName(new PartyAuthName(name.toString(), name.getId()));
        rsp.getData().code = AuthResponseData.SUCCESS;
    }


    protected PartyRegistry _partyReg;

    @Inject protected OrthPlayerRepository _playerRepo;
}
