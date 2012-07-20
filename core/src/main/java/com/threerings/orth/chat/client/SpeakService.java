//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.chat.client;

import com.threerings.presents.client.InvocationService;
import com.threerings.presents.data.ClientObject;

/**
 * An Orth chat system can register any number of speak services, each one operating via its own
 * distributed objects, e.g. rooms, games, parties, guilds, and so forth. This also means that
 * unlike tells, speak requests are never sent through server-side peers.
 */
public interface SpeakService extends InvocationService<ClientObject>
{
    void speak (String msg, InvocationListener listener);
}
