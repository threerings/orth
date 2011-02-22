//
// $Id$
package com.threerings.orth.chat.server;

import javax.annotation.Generated;

import com.threerings.orth.aether.data.PlayerName;
import com.threerings.orth.chat.client.TellService;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.server.InvocationException;
import com.threerings.presents.server.InvocationProvider;

/**
 * Defines the server-side of the {@link TellService}.
 */
@Generated(value={"com.threerings.presents.tools.GenServiceTask"},
           comments="Derived from TellService.java.")
public interface TellProvider extends InvocationProvider
{
    /**
     * Handles a {@link TellService#sendTell} request.
     */
    void sendTell (ClientObject caller, PlayerName arg1, String arg2, TellService.TellResultListener arg3)
        throws InvocationException;
}
