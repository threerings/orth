//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.party.client {

import flashx.funk.ioc.Module;

import com.threerings.presents.client.Client;
import com.threerings.presents.dobj.DObjectManager;
import com.threerings.presents.util.PresentsContext;

import com.threerings.orth.aether.client.AetherClient;
import com.threerings.orth.aether.data.AetherAuthResponseData;
import com.threerings.orth.client.OrthDeploymentConfig;
import com.threerings.orth.client.PolicyLoader;
import com.threerings.orth.party.data.PartierObject;
import com.threerings.orth.party.data.PartyCredentials;
import com.threerings.orth.party.data.PartyObjectAddress;

/**
 * Provides access to distributed object services used by the party system.
 */
public class PartyContext implements PresentsContext
{
    PartierObject
    public function PartyContext (module :Module)
    {
        _module = module;
    }

    /**
     * Connects to the given party
     */
    public function connect (address :PartyObjectAddress) :void
    {
        var pcreds :PartyCredentials = new PartyCredentials();
        pcreds.sessionToken = AetherAuthResponseData(
                _module.getInstance(AetherClient).getAuthResponseData()).sessionToken;
        pcreds.partyId = address.oid;

        var depConf :OrthDeploymentConfig = _module.getInstance(OrthDeploymentConfig);
        PolicyLoader.registerClient(_client, depConf.policyPort);

        // configure our client and logon
        _client.setVersion(depConf.version);
        _client.setServer(address.hostName, [ address.port ]);
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

    protected var _module :Module;
    protected const _client :Client = new Client();
}
}
