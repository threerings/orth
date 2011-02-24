//
// $Id$

package com.threerings.orth.chat.client;

import com.threerings.presents.client.InvocationService;

/**
 * An Orth chat system can register any number of speak services, each one operating via its own
 * distributed objects, e.g. rooms, games, parties, guilds, and so forth. This also means that
 * unlike tells, speak requests are never sent through server-side peers.
 *
 * The provider for this interface will be implemented by the
 */
public interface SpeakService extends InvocationService
{
    public void speak (String msg, InvocationListener listener);
}
