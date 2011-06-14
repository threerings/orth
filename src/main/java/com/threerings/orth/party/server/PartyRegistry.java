//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.party.server;

import com.google.inject.Inject;
import com.google.inject.Injector;
import com.google.inject.Singleton;

import com.threerings.presents.client.InvocationService.ResultListener;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.data.InvocationCodes;
import com.threerings.presents.dobj.RootDObjectManager;
import com.threerings.presents.server.ClientManager;
import com.threerings.presents.server.InvocationException;
import com.threerings.presents.server.SessionFactory;
import com.threerings.presents.server.net.PresentsConnectionManager;
import com.threerings.presents.server.InvocationManager;

import com.threerings.orth.aether.data.PlayerObject;
import com.threerings.orth.data.OrthCodes;
import com.threerings.orth.server.OrthDeploymentConfig;

import com.threerings.orth.party.data.PartyAuthName;
import com.threerings.orth.party.data.PartyCredentials;
import com.threerings.orth.party.data.PartyObject;
import com.threerings.orth.party.data.PartyObjectAddress;
import com.threerings.orth.party.data.PartyRegistryMarshaller;

/**
 * The PartyRegistry manages all the PartyManagers on a single node. It handles PartyBoard
 * requests coming from a user's world connection. Once a user is in a party, they talk
 * to their PartyManager via their party connection.
 */
@Singleton
public class PartyRegistry
    implements PartyRegistryProvider
{
    @Inject public PartyRegistry (InvocationManager invmgr, PresentsConnectionManager conmgr,
                                  ClientManager clmgr, PartyAuthenticator partyAuthor)
    {
        invmgr.registerProvider(this, PartyRegistryMarshaller.class, OrthCodes.AETHER_GROUP);
        conmgr.addChainedAuthenticator(partyAuthor);
        clmgr.addSessionFactory(SessionFactory.newSessionFactory(
                                    PartyCredentials.class, PartySession.class,
                                    PartyAuthName.class, PartyClientResolver.class));
    }

    public void createParty (ClientObject caller, String name, boolean inviteAllFriends,
        ResultListener rl)
        throws InvocationException
    {
        PlayerObject player = (PlayerObject)caller;

        if (player.party != null) {
            // TODO: possibly a better error? Surely this will be blocked on the client
            throw new InvocationException(InvocationCodes.E_INTERNAL_ERROR);
        }

        // set up the new PartyObject
        PartyObject pobj = new PartyObject();
        pobj.leaderId = player.getPlayerId();
        pobj.disband = true;
        _omgr.registerObject(pobj);

        PartyManager mgr = _injector.getInstance(PartyManager.class);
        mgr.init(pobj, player.getPlayerId());

        rl.requestProcessed(new PartyObjectAddress(_depConf.getPartyHost(), _depConf.getPartyPort(), pobj.getOid()));

        if (inviteAllFriends) {
            mgr.inviteAllFriends(player);
        }
    }

    @Inject protected OrthDeploymentConfig _depConf;
    @Inject protected Injector _injector;
    @Inject protected RootDObjectManager _omgr;
}
