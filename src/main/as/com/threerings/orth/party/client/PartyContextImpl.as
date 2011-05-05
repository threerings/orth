//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.party.client {

import flashx.funk.ioc.Module;

import com.threerings.presents.client.Client;
import com.threerings.presents.dobj.DObjectManager;

import com.threerings.orth.aether.client.AetherClient;
import com.threerings.orth.aether.data.AetherAuthResponseData;
import com.threerings.orth.client.OrthContext;
import com.threerings.orth.client.OrthDeploymentConfig;
import com.threerings.orth.client.PolicyLoader;
import com.threerings.orth.data.OrthCodes;
import com.threerings.orth.party.data.PartierObject;
import com.threerings.orth.party.data.PartyCredentials;

/**
 * Provides an implementation of the PartyContext.
 */
public class PartyContextImpl implements PartyContext
{
    public function PartyContextImpl (module :Module)
    {
        _module = module;
        _octx = _module.getInstance(OrthContext);
        _client = new Client();
    }

    /**
     * Configures our client with the supplied party hostname and port and logs on.
     */
    public function connect (partyId :int, hostname :String, port :int) :void
    {
        var pcreds :PartyCredentials = new PartyCredentials();
        pcreds.sessionToken = AetherAuthResponseData(
            _module.getInstance(AetherClient).getAuthResponseData()).sessionToken;
        pcreds.partyId = partyId;

        var depConf :OrthDeploymentConfig = _module.getInstance(OrthDeploymentConfig);
        PolicyLoader.registerClient(_client, depConf.policyPort);

        // configure our client and logon
        _client.addServiceGroup(OrthCodes.PARTY_GROUP);
        _client.setVersion(depConf.version);
        _client.setServer(hostname, [ port ]);
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

    // from PartyContext
    public function getOrthContext () :OrthContext
    {
        return _octx;
    }

    // from PartyContext
    public function getPartierObject () :PartierObject
    {
        return (_client.getClientObject() as PartierObject);
    }

    protected var _module :Module;

    protected var _octx :OrthContext;
    protected var _client :Client;
}
}
