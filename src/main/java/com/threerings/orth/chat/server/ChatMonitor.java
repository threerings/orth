//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.chat.server;

import com.threerings.orth.chat.data.Speak;
import com.threerings.orth.chat.data.Tell;

/**
 * Checks chat messages for appropriateness.
 */
public interface ChatMonitor
{
    /**
     * Return true if this tell should be allowed through.
     */
    boolean check (Tell tell);

    /**
     * Return true if this speak should be allowed through.
     */
    boolean check (Speak speak);
}
