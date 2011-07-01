//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.aether.client {
import flashx.funk.ioc.inject;

import com.threerings.presents.client.Client;
import com.threerings.presents.client.ClientEvent;

import com.threerings.orth.aether.data.FriendshipAcceptance;
import com.threerings.orth.aether.data.FriendshipRequest;
import com.threerings.orth.client.OrthContext;
import com.threerings.orth.comms.client.CommsDirector;
import com.threerings.orth.data.FriendEntry;
import com.threerings.orth.data.OrthName;

public class FriendDirector
{
    FriendEntry;
    FriendshipAcceptance;

    public function FriendDirector ()
    {
        const client :Client = inject(AetherClient);
        client.addEventListener(ClientEvent.CLIENT_DID_LOGON, function (..._) :void {
            _fsvc = client.requireService(FriendService);
        });
    }

    public function inviteFriend (invitee :OrthName) :void
    {
        _fsvc.requestFriendship(invitee.id, _octx.listener());
    }

    public function acceptFriendInvite (friendId :int) :void
    {
        _fsvc.acceptFriendshipRequest(friendId, _octx.listener());
    }

    protected var _fsvc :FriendService;

    protected const _comms :CommsDirector = inject(CommsDirector);
    protected const _octx :OrthContext = inject(OrthContext);
}
}
