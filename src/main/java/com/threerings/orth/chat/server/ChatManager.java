//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.chat.server;

import java.util.Date;
import java.util.concurrent.atomic.AtomicBoolean;

import com.google.inject.Inject;
import com.google.inject.Singleton;

import com.samskivert.util.ObserverList;

import com.threerings.util.Resulting;

import com.threerings.presents.client.InvocationService.ConfirmListener;
import com.threerings.presents.client.InvocationService.ResultListener;
import com.threerings.presents.client.InvocationService;
import com.threerings.presents.server.InvocationException;
import com.threerings.presents.server.InvocationManager;

import com.threerings.orth.aether.data.AetherClientObject;
import com.threerings.orth.aether.server.AetherNodeRequest;
import com.threerings.orth.aether.server.AetherSessionLocator;
import com.threerings.orth.aether.server.IgnoreManager;
import com.threerings.orth.chat.data.OrthChatCodes;
import com.threerings.orth.chat.data.Speak;
import com.threerings.orth.chat.data.SpeakRouter;
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
    public void sendTell (AetherClientObject caller, PlayerName tellee, String msg,
        ConfirmListener listener)
        throws InvocationException
    {
        AetherClientObject from = _locator.forClient(caller);

        final Tell tell = new Tell(from.playerName, tellee, msg);
        if (!check(tell)) {
            log.warning("Tell not sent", "from", from, "to", tellee, "msg", msg);
            return;
        }

        _history.file(tell, new Date());

        // make sure one of these folks isn't ignoring the other
        _ignoreMgr.validateCommunication(caller.getPlayerId(), tellee.getId());

        _peerMgr.invokeSingleNodeRequest(new AetherNodeRequest(tellee.getId()) {
            @Override protected void execute (AetherClientObject player, ResultListener listener) {
                TellSender.receiveTell(player, tell);
                listener.requestProcessed(null);
            }
        }, new Resulting<Void>(listener));
    }

    public void sendSpeak (SpeakRouter router, PlayerName sender, String msg, String localType,
        InvocationService.InvocationListener listener)
        throws InvocationException
    {
        Speak speak = new Speak(sender, msg, localType);
        if (!check(speak)) {
            log.warning("Speak not sent", "router", router, "from", sender, "msg", msg);
            return;
        }

        _history.file(speak, router.getSpeakReceipients(), new Date());

        router.getSpeakObject().postMessage(OrthChatCodes.SPEAK_MSG_TYPE, speak);
    }

    public void addChatMonitor (ChatMonitor monitor)
    {
        _monitors.add(monitor);
    }

    protected boolean check (final Tell tell)
    {
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
        return allow.get();
    }

    protected boolean check (final Speak speak)
    {
        final AtomicBoolean allow = new AtomicBoolean(true);
        _monitors.apply(new ObserverList.ObserverOp<ChatMonitor> () {
            @Override public boolean apply (ChatMonitor mon) {
                if (!mon.check(speak)) {
                    log.warning("Speak disallowed", "monitor", mon, "speak", speak);
                    allow.set(false);
                }
                return true;
            }
        });
        return allow.get();
    }

    protected final ObserverList<ChatMonitor> _monitors = ObserverList.newFastUnsafe();

    @Inject protected AetherSessionLocator _locator;
    @Inject protected ChatHistory _history;
    @Inject protected IgnoreManager _ignoreMgr;
    @Inject protected InvocationManager _invMgr;
    @Inject protected OrthPeerManager _peerMgr;
}
