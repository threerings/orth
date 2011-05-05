//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.chat.server;

import com.google.inject.Inject;

import com.threerings.crowd.chat.data.ChatCodes;

import com.threerings.orth.Log;
import com.threerings.orth.aether.data.PlayerObject;
import com.threerings.orth.aether.server.PlayerSessionLocator;
import com.threerings.orth.chat.data.OrthChatCodes;
import com.threerings.orth.chat.data.Tell;
import com.threerings.presents.client.InvocationService.ResultListener;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.peer.data.NodeObject;
import com.threerings.presents.peer.server.PeerManager;
import com.threerings.presents.server.ClientManager;
import com.threerings.util.Name;

public class TellNodeAction extends PeerManager.NodeRequest
{
    public TellNodeAction() {}

    public TellNodeAction (Name to, Tell tell)
    {
        _to = to;
        _tell = tell;
    }

    @Override
    public boolean isApplicable (NodeObject nodeobj)
    {
        return nodeobj.clients.containsKey(_to);
    }
    @Override
    protected void execute (ResultListener listener)
    {
        ClientObject clobj = _clMgr.getClientObject(_to);
        if (clobj != null) {
            TellSender.receiveTell(clobj, _tell);
            listener.requestProcessed(null);
        } else {
            // either something is quite wrong or we were just unlucky with the timing
            listener.requestFailed(ChatCodes.USER_NOT_ONLINE);
        }
    }

    protected Name _to;
    protected Tell _tell;

    @Inject protected transient ClientManager _clMgr;
    @Inject protected transient PlayerSessionLocator _locator;
}
