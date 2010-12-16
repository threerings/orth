//
// $Id: $

package com.threerings.orth.aether.server;

import com.google.inject.Inject;
import com.google.inject.Singleton;

import com.threerings.presents.annotation.EventThread;
import com.threerings.presents.server.InvocationManager;

import com.threerings.orth.data.OrthCodes;

/**
 * Manage Orth Players.
 */
@Singleton @EventThread
public class AetherManager
    implements PlayerProvider
{
    @Inject public AetherManager (InvocationManager invmgr)
    {
        // register our bootstrap invocation service
        invmgr.registerDispatcher(new PlayerDispatcher(this), OrthCodes.AETHER_GROUP);
    }
}
