//
// $Id$

package com.threerings.orth.chat.server;

import com.google.inject.Inject;

import com.threerings.crowd.chat.data.ChatCodes;
import com.threerings.orth.aether.data.PlayerObject;
import com.threerings.orth.aether.server.PlayerLocator;
import com.threerings.orth.chat.data.Tell;
import com.threerings.util.Name;

import com.threerings.presents.data.ClientObject;
import com.threerings.presents.peer.data.NodeObject;
import com.threerings.presents.peer.server.PeerManager;
import com.threerings.presents.server.ClientManager;

import com.threerings.orth.chat.client.TellService.TellResultListener;

public class TellNodeAction extends PeerManager.NodeAction
{
    public TellNodeAction (Name to, Tell tell, TellResultListener listener)
    {
        _to = to;
        _tell = tell;
        _listener = listener;
    }

    @Override
    public boolean isApplicable (NodeObject nodeobj)
    {
        return nodeobj.clients.containsKey(_to);
    }

    @Override
    protected void execute ()
    {
        ClientObject clobj = _clMgr.getClientObject(_to);
        if (clobj != null) {
            PlayerObject player = _locator.forClient(clobj);
            player.postMessage(ChatCodes.USER_CHAT_TYPE, _tell);
            _listener.tellSucceeded();
            return;
        }

        // either something is quite wrong or we were just unlucky with the timing
        _listener.requestFailed(ChatCodes.USER_NOT_ONLINE);
    }

    protected Name _to;
    protected Tell _tell;
    protected TellResultListener _listener;

    @Inject protected transient ClientManager _clMgr;
    @Inject protected transient PlayerLocator _locator;
}
