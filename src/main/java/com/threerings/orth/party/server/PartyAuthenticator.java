//
// $Id: PartyAuthenticator.java 19629 2010-11-24 16:40:04Z zell $

package com.threerings.orth.party.server;

import java.util.concurrent.Callable;

import com.google.inject.Inject;
import com.google.inject.Singleton;
import com.samskivert.util.ServiceWaiter;

import com.threerings.presents.net.AuthResponse;
import com.threerings.presents.net.AuthResponseData;

import com.threerings.presents.server.ChainedAuthenticator;
import com.threerings.presents.server.PresentsDObjectMgr;
import com.threerings.presents.server.net.AuthingConnection;

import com.threerings.orth.data.AuthName;
import com.threerings.orth.data.OrthAuthCodes;
import com.threerings.orth.data.OrthName;

import com.threerings.orth.party.data.PartyAuthName;
import com.threerings.orth.party.data.PartyCodes;
import com.threerings.orth.party.data.PartyCredentials;

import com.threerings.orth.server.persist.OrthPlayerRecord;
import com.threerings.orth.server.persist.OrthPlayerRepository;

import static com.threerings.orth.Log.log;

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

    public PartyAuthenticator ()
    {
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
        conn.setAuthName(new PartyAuthName(player.getPlayerName(), player.getPlayerId()));
        rsp.getData().code = AuthResponseData.SUCCESS;

        // TODO(bruno): Enable
        //_partyReg.preJoinParty(
        //    new OrthName(player.getPlayerName(), player.getPlayerId()),
        //    creds.partyId);
    }


    protected PartyRegistry _partyReg;

    @Inject protected OrthPlayerRepository _playerRepo;
}
