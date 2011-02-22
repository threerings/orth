//
// $Id$

package com.threerings.orth.chat.client;

import com.threerings.presents.client.InvocationService;
import com.threerings.presents.client.InvocationService.ConfirmListener;

import com.threerings.orth.aether.data.PlayerName;

/**
 * Each Orth chat system should have one tell service configured. Tells go from the client
 * over the aether connection directly to the {@link ChatManager}, which implements this
 * service's provider.
 */
public interface TellService extends InvocationService
{
    public static interface TellResultListener extends InvocationListener
    {
        void tellSucceeded ();
    }

    public void sendTell (PlayerName player, String tell, TellResultListener listener);
}
