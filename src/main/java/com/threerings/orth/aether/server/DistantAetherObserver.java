//
// Who - Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.aether.server;

import com.threerings.util.Name;

import com.threerings.orth.aether.data.AetherAuthName;
import com.threerings.orth.peer.server.OrthPeerManager.FarSeeingObserver;

public abstract class DistantAetherObserver
    implements FarSeeingObserver
{
    @Override public void loggedOn (String node, Name member) {
        if (member instanceof AetherAuthName) {
            aetherLogOn(node, ((AetherAuthName) member));
        }
    }

    @Override public void loggedOff (String node, Name member) {
        if (member instanceof AetherAuthName) {
            aetherLogOff(node, ((AetherAuthName) member));
        }
    }

    protected abstract void aetherLogOn (String node, AetherAuthName member);

    protected abstract void aetherLogOff (String node, AetherAuthName member);
}
