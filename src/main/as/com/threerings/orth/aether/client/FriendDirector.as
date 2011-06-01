//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.aether.client {
import flashx.funk.ioc.inject;

import org.osflash.signals.Signal;

import com.threerings.presents.client.Client;
import com.threerings.presents.client.ClientEvent;

import com.threerings.orth.aether.data.PlayerName;
import com.threerings.orth.client.OrthContext;

public class FriendDirector implements FriendReceiver
{
    public const onFriendshipRequested :Signal = new Signal(PlayerName);

    public function FriendDirector ()
    {
        const client :Client = inject(AetherClient);
        client.getInvocationDirector().registerReceiver(new FriendDecoder(this));
        client.addEventListener(ClientEvent.CLIENT_DID_LOGON, function (..._) :void {
            _fsvc = client.requireService(FriendService);
        });
    }

    public function friendshipRequested (requester :PlayerName) :void
    {
        onFriendshipRequested.dispatch(requester);
    }

    public function inviteFriend (playerId :int) :void
    {
        _fsvc.requestFriendship(playerId, _octx.listener());
    }

    public function acceptFriendInvite (friendId :int) :void
    {
        _fsvc.acceptFriendshipRequest(friendId, _octx.listener());
    }

    protected var _fsvc :FriendService;

    protected const _octx :OrthContext = inject(OrthContext);
}
}
