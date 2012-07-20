//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.peer.server;

import com.threerings.presents.peer.data.NodeObject;
import com.threerings.presents.peer.server.PeerManager.NodeRequest;

/**
 * A NodeRequest that runs on every node.
 */
public abstract class EveryNodeRequest extends NodeRequest
{
    @Override
    final public boolean isApplicable (NodeObject nodeobj)
    {
        return true;
    }
}
