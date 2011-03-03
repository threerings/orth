//
// $Id$

package com.threerings.orth.chat.client;

import com.threerings.presents.client.InvocationService;

/**
 * Each Orth chat system should have one tell service configured. Tells go from the client
 * over the aether connection directly to the {@link ChatManager}, which implements this
 * service's provider.
 */
public interface TellService extends InvocationService
{
    public void sendTell (int playerId, String tell, ConfirmListener listener);
}
