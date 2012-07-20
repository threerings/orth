//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.aether.server;

import com.google.inject.Inject;

import com.threerings.presents.client.InvocationService.ResultListener;
import com.threerings.presents.client.InvocationService;
import com.threerings.presents.peer.data.NodeObject;
import com.threerings.presents.peer.server.PeerManager.NodeRequest;

import com.threerings.orth.aether.data.AetherAuthName;
import com.threerings.orth.aether.data.AetherClientObject;
import com.threerings.orth.aether.data.AetherCodes;

import static com.threerings.orth.Log.log;

/**
 * Request that applies to a node that a specified aether player is on and invokes the subclass'
 * {@link #execute(AetherClientObject, InvocationService.ResultListener)} method with the player
 * object.
 */
public abstract class AetherNodeRequest extends NodeRequest
{
    /**
     * Creates a new requests targeting the given player id.
     */
    public AetherNodeRequest (int targetPlayerId)
    {
        _targetPlayer = AetherAuthName.makeKey(targetPlayerId);
    }

    @Override // from NodeRequest
    public boolean isApplicable (NodeObject nodeobj)
    {
        if (nodeobj == null || nodeobj.clients == null) {
            log.warning("isApplicable with bizarre nodeobj", "nodeobj", nodeobj);
            return false;
        }
        return nodeobj.clients.containsKey(_targetPlayer);
    }

    @Override // from NodeRequest
    protected void execute (ResultListener listener)
    {
        AetherClientObject player = _playerLocator.lookupPlayer(_targetPlayer.getId());
        if (player == null || !player.isActive()) {
            listener.requestFailed(AetherCodes.USER_NOT_ONLINE);
            return;
        }
        execute(player, listener);
    }

    /**
     * Execute the request on the given player and yields a result or failure.
     * @param player the requested player
     * @param listener on which to invoke success or failure
     */
    protected abstract void execute (AetherClientObject player, ResultListener listener);

    protected AetherAuthName _targetPlayer;
    @Inject transient protected AetherSessionLocator _playerLocator;
}
