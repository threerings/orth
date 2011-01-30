//
// $Id: PartyContextImpl.as 16175 2009-04-23 20:56:15Z ray $

package com.threerings.orth.party.client {

import flashx.funk.ioc.inject;

import com.threerings.presents.client.Client;
import com.threerings.presents.dobj.DObjectManager;

import com.threerings.orth.aether.client.AetherClient;
import com.threerings.orth.client.OrthContext;
import com.threerings.orth.client.OrthDeploymentConfig;
import com.threerings.orth.client.PolicyLoader;
import com.threerings.orth.data.OrthCodes;
import com.threerings.orth.data.OrthCredentials;

import com.threerings.orth.room.client.RoomContext;

import com.threerings.orth.party.data.PartierObject;
import com.threerings.orth.party.data.PartyCredentials;

/**
 * Provides an implementation of the PartyContext.
 */
public class PartyContextImpl implements PartyContext
{
    public function PartyContextImpl ()
    {
        _client = new Client(null);
    }

    /**
     * Configures our client with the supplied party hostname and port and logs on.
     */
    public function connect (partyId :int, hostname :String, port :int) :void
    {
        var pcreds :PartyCredentials = new PartyCredentials(null);
        pcreds.sessionToken = OrthCredentials(inject(AetherClient).getCredentials()).sessionToken;
        pcreds.partyId = partyId;

        PolicyLoader.registerClient(_client, _depConf.policyPort);

        // configure our client and logon
        _client.addServiceGroup(OrthCodes.PARTY_GROUP);
        _client.setVersion(_depConf.version);
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
        return _ctx;
    }

    // from PartyContext
    public function getPartierObject () :PartierObject
    {
        return (_client.getClientObject() as PartierObject);
    }

    protected const _ctx :OrthContext = inject(OrthContext);
    protected const _depConf :OrthDeploymentConfig = inject(OrthDeploymentConfig);

    protected var _client :Client;
}
}