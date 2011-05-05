//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.aether.server;

import com.google.inject.Inject;

import com.threerings.orth.aether.data.AetherAuthName;
import com.threerings.orth.aether.data.AetherCodes;
import com.threerings.orth.aether.data.PlayerObject;
import com.threerings.presents.client.InvocationService.ResultListener;
import com.threerings.presents.peer.data.NodeObject;
import com.threerings.presents.peer.server.PeerManager.NodeRequest;

/**
 * Request that applies to a node that a specified aether player is on and invokes the subclass'
 * {@link #execute(PlayerObject, ResultListener)} method with the player object.
 */
public abstract class PlayerNodeRequest extends NodeRequest
{
    /**
     * Creates a new requests targeting the given player id.
     */
    public PlayerNodeRequest (int targetPlayerId)
    {
        _targetPlayer = AetherAuthName.makeKey(targetPlayerId);
    }

    @Override // from NodeRequest
    public boolean isApplicable (NodeObject nodeobj)
    {
        return nodeobj.clients.containsKey(_targetPlayer);
    }

    @Override // from NodeRequest
    protected void execute (ResultListener listener)
    {
        PlayerObject player = _playerLocator.lookupPlayer(_targetPlayer.getId());
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
    protected abstract void execute (PlayerObject player, ResultListener listener);

    protected AetherAuthName _targetPlayer;
    @Inject transient protected PlayerSessionLocator _playerLocator;
}
