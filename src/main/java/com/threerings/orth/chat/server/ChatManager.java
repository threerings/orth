//
// $Id$

package com.threerings.orth.chat.server;

import com.google.inject.Inject;
import com.google.inject.Singleton;

import com.threerings.presents.data.ClientObject;
import com.threerings.presents.server.InvocationException;
import com.threerings.presents.server.InvocationManager;
import com.threerings.presents.peer.server.PeerManager;

import com.threerings.orth.aether.data.PlayerName;
import com.threerings.orth.aether.data.PlayerObject;
import com.threerings.orth.aether.server.PlayerLocator;
import com.threerings.orth.data.AuthName;
import com.threerings.orth.chat.data.Tell;

import com.threerings.orth.chat.client.TellService.TellResultListener;
import com.threerings.orth.chat.data.OrthChatCodes;
import com.threerings.orth.chat.data.SpeakMarshaller;
import com.threerings.orth.chat.data.SpeakObject;
import com.threerings.orth.chat.data.TellMarshaller;

@Singleton
public class ChatManager
    implements TellProvider
{
    @Inject public ChatManager ()
    {
    }

    public void init ()
    {
        // ORTH TODO: Bootstrap group?
        _invMgr.registerProvider(this, TellMarshaller.class);
    }

    /**
     * Called when a new {@link SpeakObject} comes into existence and needs speaking to
     * work through it. The returned provider
     */
    public SpeakMarshaller registerSpeakObject (SpeakObject speakObj)
    {
        SpeakProvider provider = new OrthSpeakProvider(speakObj, _locator);

        return _invMgr.registerProvider(provider, SpeakMarshaller.class);
    }

    // from TellProvider
    public void sendTell (ClientObject caller, PlayerName to, String msg,
            final TellResultListener listener)
        throws InvocationException
    {
        PlayerObject from = _locator.forClient(caller);

        Tell tell = new Tell(from.playerName, msg);

        _peerMgr.invokeNodeAction(
            new TellNodeAction(AuthName.makeKey(to.getId()), tell, listener),
            new Runnable() {
                public void run () {
                    listener.requestFailed(OrthChatCodes.USER_NOT_ONLINE);
                }
        });
    }

    @Inject protected PlayerLocator _locator;
    @Inject protected InvocationManager _invMgr;
    @Inject protected PeerManager _peerMgr;
}
