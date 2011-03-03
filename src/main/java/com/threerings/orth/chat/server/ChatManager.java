//
// $Id$

package com.threerings.orth.chat.server;

import com.google.inject.Inject;
import com.google.inject.Singleton;

import com.threerings.presents.client.InvocationService.ConfirmListener;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.peer.server.PeerManager;
import com.threerings.presents.server.InvocationException;
import com.threerings.presents.server.InvocationManager;

import com.threerings.orth.aether.data.PlayerObject;
import com.threerings.orth.aether.server.PlayerLocator;
import com.threerings.orth.chat.data.OrthChatCodes;
import com.threerings.orth.chat.data.SpeakMarshaller;
import com.threerings.orth.chat.data.SpeakObject;
import com.threerings.orth.chat.data.Tell;
import com.threerings.orth.chat.data.TellMarshaller;
import com.threerings.orth.data.AuthName;
import com.threerings.orth.data.OrthCodes;

@Singleton
public class ChatManager
    implements TellProvider
{
    public void init ()
    {
        _invMgr.registerProvider(this, TellMarshaller.class, OrthCodes.AETHER_GROUP);
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
    public void sendTell (ClientObject caller, int playerId, String msg,
            final ConfirmListener listener)
        throws InvocationException
    {
        PlayerObject from = _locator.forClient(caller);

        Tell tell = new Tell(from.playerName, msg);

        _peerMgr.invokeNodeAction(
            new TellNodeAction(AuthName.makeKey(playerId), tell, listener),
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
