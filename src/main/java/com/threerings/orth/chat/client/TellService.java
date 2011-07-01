//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.chat.client;

import com.threerings.presents.client.InvocationService;

import com.threerings.orth.chat.server.ChatManager;
import com.threerings.orth.data.OrthName;

/**
 * Each Orth chat system should have one tell service configured. Tells go from the client
 * over the aether connection directly to the {@link ChatManager}, which implements this
 * service's provider.
 */
public interface TellService extends InvocationService
{
    public void sendTell (OrthName tellee, String tell, ConfirmListener listener);
}
