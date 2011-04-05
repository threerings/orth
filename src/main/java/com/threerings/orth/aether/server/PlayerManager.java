//
// $Id$

package com.threerings.orth.aether.server;

import com.google.inject.Inject;
import com.google.inject.Singleton;

import com.threerings.presents.annotation.EventThread;
import com.threerings.presents.server.ClientManager;
import com.threerings.presents.server.PresentsSession;

import com.threerings.orth.aether.data.PlayerObject;
import com.threerings.orth.aether.server.PlayerSessionLocator;

@Singleton @EventThread
public class PlayerManager
{
    /**
     * Boots a player from the server.  Must be called on the dobjmgr thread.
     *
     * @return true if the player was found and booted successfully
     */
    public boolean bootPlayer (final int playerId)
    {
        final PlayerObject mobj = _locator.lookupPlayer(playerId);
        if (mobj != null) {
            final PresentsSession pclient = _clmgr.getClient(mobj.username);
            if (pclient != null) {
                pclient.endSession();
                return true;
            }
        }
        return false;
    }

    @Inject protected ClientManager _clmgr;
    @Inject protected PlayerSessionLocator _locator;
}
