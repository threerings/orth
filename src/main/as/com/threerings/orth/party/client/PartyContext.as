//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.party.client {

import flashx.funk.ioc.Module;
import flashx.funk.ioc.inject;

import com.threerings.presents.client.Client;
import com.threerings.presents.dobj.DObjectManager;
import com.threerings.presents.util.PresentsContext;

import com.threerings.orth.aether.client.AetherClient;
import com.threerings.orth.client.OrthDeploymentConfig;
import com.threerings.orth.client.PolicyLoader;
import com.threerings.orth.comms.client.CommsDirector;
import com.threerings.orth.comms.data.CommDecoder;
import com.threerings.orth.party.data.PartierObject;
import com.threerings.orth.party.data.PartyCredentials;
import com.threerings.orth.party.data.PartyObjectAddress;

/**
 * Provides access to distributed object services used by the party system.
 */
public class PartyContext implements PresentsContext
{
    PartierObject;

    /**
     * Connects to the given party
     */
    public function connect (address :PartyObjectAddress) :void
    {
        const pcreds :PartyCredentials = new PartyCredentials();
        pcreds.sessionToken = AetherClient(_module.getInstance(AetherClient)).sessionToken;
        pcreds.partyId = address.oid;

        PolicyLoader.registerClient(_client, _depConf.policyPort);

        // Allow the party connection to send comms over our existing director
        _client.getInvocationDirector().registerReceiver(new CommDecoder(_comms));

        // configure our client and logon
        _client.setVersion(_depConf.version);
        _client.setServer(address.host, address.ports);
        _client.setCredentials(pcreds);
        _client.logon();
    }

    // from PresentsContext
    public function getClient () :Client
    {
        return _client;
    }

    // from PresentsContext
    public function getDObjectManager () :DObjectManager
    {
        return _client.getDObjectManager();
    }

    protected const _comms :CommsDirector = inject(CommsDirector);
    protected const _module :Module = inject(Module);
    protected const _depConf :OrthDeploymentConfig = inject(OrthDeploymentConfig);
    protected const _client :Client = new Client();
}
}
