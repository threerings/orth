//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.data;

import com.threerings.io.SimpleStreamableObject;

/**
 * Extracts the funk module on the client side. Extend this class to provide access to the
 * connection's module in the streamable. This is not generated on the client side, so any added
 * fields will not be automatically deserialized.
 */
public class ModuleStreamable extends SimpleStreamableObject
{
}
