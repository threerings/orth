//
// $Id: $

package com.threerings.orth.player.server;

import com.google.inject.Inject;
import com.google.inject.Singleton;

import com.threerings.presents.annotation.EventThread;
import com.threerings.presents.server.InvocationManager;

import com.threerings.orth.player.data.OrthCodes;

/**
 * Manage Orth Players.
 */
@Singleton @EventThread
public class PlayerManager
    implements PlayerProvider
{
    @Inject public PlayerManager (InvocationManager invmgr)
    {
        // register our bootstrap invocation service
        invmgr.registerDispatcher(new PlayerDispatcher(this), OrthCodes.PLAYER_GROUP);
    }
}
