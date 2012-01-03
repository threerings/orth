//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.party.server;

import com.google.inject.AbstractModule;
import com.google.inject.Inject;
import com.google.inject.Injector;
import com.google.inject.Singleton;

import com.threerings.presents.client.InvocationService.ResultListener;
import com.threerings.presents.data.InvocationCodes;
import com.threerings.presents.server.ClientManager;
import com.threerings.presents.server.InvocationException;
import com.threerings.presents.server.InvocationManager;
import com.threerings.presents.server.SessionFactory;
import com.threerings.presents.server.net.PresentsConnectionManager;

import com.threerings.orth.aether.data.AetherClientObject;
import com.threerings.orth.data.OrthCodes;
import com.threerings.orth.party.data.PartyAuthName;
import com.threerings.orth.party.data.PartyCredentials;
import com.threerings.orth.party.data.PartyRegistryMarshaller;

import static com.threerings.orth.Log.log;

/**
 * The PartyRegistry creates PartyManagers on a single node. Once a user is in a party, they talk
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

    public void createParty (AetherClientObject caller, ResultListener rl)
        throws InvocationException
    {
        final AetherClientObject player = caller;

        if (player.party != null) {
            log.warning("Player tried to create party while already in one", "player", player);
            throw new InvocationException(InvocationCodes.E_INTERNAL_ERROR);
        }
        PartyManager mgr = _injector.createChildInjector(new AbstractModule() {
            @Override protected void configure () {
                bind(AetherClientObject.class).toInstance(player);
            }
        }).getInstance(PartyManager.class);
        rl.requestProcessed(mgr.addr);
    }

    @Inject protected Injector _injector;
}
