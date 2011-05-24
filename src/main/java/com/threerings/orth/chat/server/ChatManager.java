//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.chat.server;

import com.google.inject.Inject;
import com.google.inject.Singleton;

import com.threerings.orth.aether.data.PlayerObject;
import com.threerings.orth.aether.server.PlayerNodeRequest;
import com.threerings.orth.aether.server.PlayerNodeRequests;
import com.threerings.orth.aether.server.PlayerSessionLocator;
import com.threerings.orth.chat.data.Tell;
import com.threerings.orth.chat.data.TellMarshaller;
import com.threerings.orth.data.OrthCodes;
import com.threerings.presents.client.InvocationService.ConfirmListener;
import com.threerings.presents.client.InvocationService.ResultListener;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.server.InvocationException;
import com.threerings.presents.server.InvocationManager;
import com.threerings.util.Resulting;

@Singleton
public class ChatManager
    implements TellProvider
{
    public void init ()
    {
        _invMgr.registerProvider(this, TellMarshaller.class, OrthCodes.AETHER_GROUP);
    }

    // from TellProvider
    public void sendTell (ClientObject caller, int playerId, String msg, ConfirmListener listener)
        throws InvocationException
    {
        PlayerObject from = _locator.forClient(caller);

        _playerNode.invokeOnPlayerNode(new TellRequest(playerId, new Tell(from.playerName, msg)),
            new Resulting<Void>(listener));
    }

    protected static class TellRequest extends PlayerNodeRequest {
        protected TellRequest (int targetPlayerId, Tell tell) {
            super(targetPlayerId);
            _tell = tell;
        }

        @Override protected void execute (PlayerObject player, ResultListener listener) {
            TellSender.receiveTell(player, _tell);
            listener.requestProcessed(null);
        }

        protected Tell _tell;
    }

    @Inject protected PlayerSessionLocator _locator;
    @Inject protected InvocationManager _invMgr;
    @Inject protected PlayerNodeRequests _playerNode;
}
