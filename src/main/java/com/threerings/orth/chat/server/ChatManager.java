//
// $Id$

package com.threerings.orth.chat.server;

import com.google.inject.Inject;
import com.google.inject.Singleton;

import com.threerings.presents.data.ClientObject;
import com.threerings.presents.peer.server.PeerManager;

import com.threerings.crowd.chat.data.ChatCodes;

import com.threerings.orth.aether.data.PlayerName;
import com.threerings.orth.aether.data.PlayerObject;
import com.threerings.orth.aether.server.PlayerLocator;
import com.threerings.orth.data.AuthName;
import com.threerings.orth.data.Tell;

import com.threerings.orth.chat.client.TellService.TellResultListener;
import com.threerings.orth.chat.server.TellProvider;

@Singleton
public class ChatManager
    implements TellProvider
{
    public ChatManager ()
    {
    }

    public void sendTell (ClientObject caller, PlayerName to, String msg,
        final TellResultListener listener)
    {
        PlayerObject from = _locator.forClient(caller);

        Tell tell = new Tell(from.playerName, msg);

        _peerMgr.invokeNodeAction(
            new TellNodeAction(AuthName.makeKey(to.getId()), tell, listener),
            new Runnable() {
                public void run () {
                    listener.requestFailed(ChatCodes.USER_NOT_ONLINE);
                }
        });
    }

    @Inject protected PlayerLocator _locator;
    @Inject protected PeerManager _peerMgr;
}
