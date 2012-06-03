//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.aether.client;

import com.threerings.presents.client.InvocationService;

import com.threerings.orth.aether.data.AetherClientObject;

/**
 * Requests from an Orth client to the Aether server related to their ignore list.
 */
public interface IgnoreService
    extends InvocationService<AetherClientObject>
{
    /**
     * Requests that the specified player be added or removed to the local player's ignore list,
     * depending on the boolean argument. There is no return argument, but successful execution
     * results in a change to the ignorer's {@link AetherClientObject#ignoring} as well as to the
     * ignoree's {@link AetherClientObject#ignoredBy}.
     */
    void ignorePlayer (int playerId, boolean ignore, InvocationListener listener);
}
