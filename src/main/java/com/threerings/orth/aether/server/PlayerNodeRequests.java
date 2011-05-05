//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.
package com.threerings.orth.aether.server;

import java.util.Set;

import com.google.inject.Inject;
import com.google.inject.Singleton;

import com.samskivert.util.ResultListener;

import com.threerings.presents.client.InvocationService;
import com.threerings.presents.peer.server.PeerManager.NodeRequest;
import com.threerings.util.Resulting;

import com.threerings.orth.aether.data.PlayerObject;
import com.threerings.orth.notify.data.Notification;
import com.threerings.orth.notify.server.NotificationManager;
import com.threerings.orth.peer.server.OrthPeerManager;

import static com.threerings.orth.Log.log;

/**
 * Facilitates sending player requests via the peer manager.
 */
@Singleton
public class PlayerNodeRequests
{
    /**
     * Sends a notification to a logged in player.
     */
    public void sendNotification (int playerId, final Notification notification,
        ResultListener<Void> listener)
    {
        invokeOnPlayerNode(new PlayerNodeRequest(playerId) {
            @Inject transient NotificationManager notMgr;
            @Override protected void execute (PlayerObject target,
                    InvocationService.ResultListener listener) {
                notMgr.notify(target, notification);
                listener.requestProcessed(null);
            }
        }, listener);
    }

    /**
     * Invokes the given request on exactly one node, failing if none or more than one is found.
     */
    public <T> void invokeOnPlayerNode (NodeRequest request, ResultListener<T> lner)
    {
        Set<String> nodes = _peerMan.findApplicableNodes(request);
        int size = nodes.size();
        if (size != 1) {
            lner.requestFailed(new Exception(size == 0 ?
                    "e.player_not_found" : "e.internal_error"));
            if (size > 1) {
                log.warning("Player request target is on multiple nodes, dropping",
                    "request", request, "nodes", nodes);
            }
            return;
        }

        _peerMan.invokeNodeRequest(nodes.iterator().next(), request, new Resulting<T>(lner));
    }

    @Inject protected OrthPeerManager _peerMan;
}
