//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.aether.client {
import com.threerings.util.Config;
import com.threerings.util.F;
import com.threerings.util.Log;

import com.threerings.presents.client.Client;
import com.threerings.presents.client.ConfirmAdapter;
import com.threerings.presents.client.ResultAdapter;

import com.threerings.orth.client.Listeners;
import com.threerings.orth.nodelet.data.HostedNodelet;
import com.threerings.orth.party.client.PartyDirector;
import com.threerings.orth.party.client.PartyRegistryService;
import com.threerings.orth.party.data.PartyConfig;
import com.threerings.orth.party.data.PartyNodelet;

/**
 * Handles player-oriented requests.
 */
public class AetherDirector extends AetherDirectorBase
{
    public function acceptGuildInvite (senderId :int, guildId :int) :void
    {
        _asvc.acceptGuildInvite(senderId, guildId, Listeners.listener());
    }

    public function createGuild (name :String, confirmed :Function, failed :Function) :void
    {
        _asvc.createGuild(name, new ConfirmAdapter(confirmed, failed));
    }

    /**
     * Create a new party.
     */
    public function createParty (success :Function = null, failure :Function = null) :void
    {
        doCreate(new PartyConfig(), success, failure);
    }

    /**
     * Join a party.
     */
    public function joinParty (party :HostedNodelet, success :Function = null,
        failure :Function = null) :void
    {
        _prsvc.joinParty(PartyNodelet(party.nodelet).partyId, new ResultAdapter(
            (success != null) ? success : F.id, (failure != null) ? failure : F.id));
    }

    protected function get partyDir () :PartyDirector
    {
        return _module.getInstance(PartyDirector);
    }

    protected function doCreate (config :PartyConfig, success :Function = null,
        failure :Function = null) :void
    {
        _prsvc.createParty(config, new ResultAdapter(
            (success != null) ? success : F.id, (failure != null) ? failure : F.id));
    }

    override protected function clientObjectUpdated (client :Client) :void
    {
        super.clientObjectUpdated(client);

        const pDir :PartyDirector = _module.getInstance(PartyDirector);

        // if our authoritative party address changes, follow it
        aetherObj.partyChanged.add(partyDidChange);

        if (aetherObj.party != null) {
            partyDidChange(aetherObj.party);
        } else {
            pDir.aetherIsReady();
        }
    }

    protected function partyDidChange (party :HostedNodelet, oldParty :HostedNodelet = null) :void
    {
        partyDir.connectToParty(party);
    }

    override protected function fetchServices (client :Client) :void
    {
        _asvc = client.requireService(AetherService);
        _prsvc = client.requireService(PartyRegistryService);
     }

    protected var _asvc :AetherService;
    protected var _prsvc :PartyRegistryService;

    private static const log :Log = Log.getLog(AetherDirector);
}
}
