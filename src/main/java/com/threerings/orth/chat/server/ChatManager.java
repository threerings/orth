//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.chat.server;

import java.util.concurrent.atomic.AtomicBoolean;

import com.google.inject.Inject;
import com.google.inject.Singleton;

import com.samskivert.util.ObserverList;

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

import static com.threerings.orth.Log.log;

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

        final AtomicBoolean allow = new AtomicBoolean(true);
        _monitors.apply(new ObserverList.ObserverOp<ChatMonitor> () {
            @Override public boolean apply (ChatMonitor mon) {
                if (!mon.check(tell)) {
                    log.warning("Tell disallowed", "monitor", mon, "tell", tell);
                    allow.set(false);
                }
                return true;
            }
        });
        if (!allow.get()) {
            return;
        }

        _peerMgr.invokeSingleNodeRequest(new AetherNodeRequest(tellee.getId()) {
            @Override protected void execute (AetherClientObject player, ResultListener listener) {
                TellSender.receiveTell(player, tell);
                listener.requestProcessed(null);

            }
        }, new Resulting<Void>(listener));
    }

    public void addChatMonitor (ChatMonitor monitor)
    {
        _monitors.add(monitor);
    }

    @Inject protected AetherSessionLocator _locator;
    @Inject protected InvocationManager _invMgr;
    @Inject protected OrthPeerManager _peerMgr;
    protected final ObserverList<ChatMonitor> _monitors = ObserverList.newFastUnsafe();
}
