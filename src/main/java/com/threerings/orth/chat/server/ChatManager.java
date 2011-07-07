//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.chat.server;

import com.google.inject.Inject;
import com.google.inject.Singleton;

import com.threerings.util.Resulting;

import com.threerings.presents.client.InvocationService.ConfirmListener;
import com.threerings.presents.client.InvocationService.ResultListener;
import com.threerings.presents.server.InvocationException;
import com.threerings.presents.server.InvocationManager;

import com.threerings.orth.aether.data.AetherClientObject;
import com.threerings.orth.aether.server.AetherNodeRequest;
import com.threerings.orth.aether.server.AetherSessionLocator;
import com.threerings.orth.chat.data.Tell;
import com.threerings.orth.chat.data.TellMarshaller;
import com.threerings.orth.data.OrthCodes;
import com.threerings.orth.data.PlayerName;
import com.threerings.orth.peer.server.OrthPeerManager;

@Singleton
public class ChatManager
    implements TellProvider
{
    public void init ()
    {
        _invMgr.registerProvider(this, TellMarshaller.class, OrthCodes.AETHER_GROUP);
    }

    // from TellProvider
    public void sendTell (AetherClientObject caller, PlayerName tellee, String msg, ConfirmListener listener)
        throws InvocationException
    {
        AetherClientObject from = _locator.forClient(caller);
        final Tell tell = new Tell(from.playerName, tellee, msg);
        _peerMgr.invokeSingleNodeRequest(new AetherNodeRequest(tellee.getId()) {
            @Override protected void execute (AetherClientObject player, ResultListener listener) {
                TellSender.receiveTell(player, tell);
                listener.requestProcessed(null);

            }
        }, new Resulting<Void>(listener));
    }

    @Inject protected AetherSessionLocator _locator;
    @Inject protected InvocationManager _invMgr;
    @Inject protected OrthPeerManager _peerMgr;
}
