//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.aether.server;

import com.google.inject.Inject;

import com.threerings.presents.peer.data.NodeObject;
import com.threerings.presents.peer.server.PeerManager;

import com.threerings.orth.aether.data.AetherAuthName;
import com.threerings.orth.aether.data.AetherClientObject;

import static com.threerings.orth.Log.log;

/**
 * An action to be invoked on every server on which a player is logged in. You must read {@link
 * PeerManager.NodeAction} for caveats before using this class.
 */
public abstract class AetherNodeAction extends PeerManager.NodeAction
{
    public AetherNodeAction (int playerId)
    {
        _playerId = playerId;
    }

    @Override // from PeerManager.NodeAction
    public boolean isApplicable (NodeObject nodeobj)
    {
        return nodeobj.clients.containsKey( AetherAuthName.makeKey(_playerId));
    }

    @Override // from PeerManager.NodeAction
    protected void execute ()
    {
        AetherClientObject memobj = _locator.lookupPlayer(_playerId);
        if (memobj != null) {
            if (!memobj.isActive()) {
                log.warning("Got an inactive player from the locator!?", "who", memobj.username);
            } else {
                execute(memobj);
            }
        } // if not, oh well, they went away
    }

    protected abstract void execute (AetherClientObject memobj);

    protected int _playerId;

    /** Used to look up player objects. */
    @Inject protected transient AetherSessionLocator _locator;
}
