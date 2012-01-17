//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.aether.client {
import flashx.funk.ioc.inject;

import com.threerings.presents.client.Client;

import com.threerings.orth.aether.data.FriendLogOnOffComm;
import com.threerings.orth.aether.data.FriendshipAcceptance;
import com.threerings.orth.aether.data.FriendshipRequest;
import com.threerings.orth.client.Listeners;
import com.threerings.orth.comms.client.CommsDirector;
import com.threerings.orth.data.FriendEntry;
import com.threerings.orth.data.PlayerName;

public class FriendDirector extends AetherDirectorBase
{
    FriendEntry;
    FriendshipRequest;
    FriendshipAcceptance;

    public function inviteFriend (invitee :PlayerName) :void
    {
        _fsvc.requestFriendship(invitee.id, Listeners.listener());
    }

    public function acceptFriendInvite (friendId :int) :void
    {
        _fsvc.acceptFriendshipRequest(friendId, Listeners.listener());
    }

    override protected function clientObjectUpdated (client :Client) :void
    {
        super.clientObjectUpdated(client);

        aetherObj.friendsEntryUpdated.add(onFriendUpdate);
    }

    override protected function fetchServices (client :Client) :void
    {
        _fsvc = client.requireService(FriendService);
    }

    protected function onFriendUpdate (entry :FriendEntry, oldEntry :FriendEntry) :void
    {
        // if they either went from online to offline or vice versa, send a notification
        if (oldEntry.online != entry.online) {
            _comms.receiveComm(new FriendLogOnOffComm(
                entry.name, aetherObj.playerName, entry.online));
        }
    }

    protected var _fsvc :FriendService;

    protected const _comms :CommsDirector = inject(CommsDirector);
}
}
