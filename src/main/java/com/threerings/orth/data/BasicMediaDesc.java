//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.data;

import com.threerings.io.SimpleStreamableObject;

/**
 * An implementation base for certain kinds of {@link MediaDesc}.
 */
public abstract class BasicMediaDesc extends SimpleStreamableObject
    implements MediaDesc
{
    protected BasicMediaDesc ()
    {
    }

    protected BasicMediaDesc (byte mimeType)
    {
        _mimeType = mimeType;
    }

    public byte getMimeType ()
    {
        return _mimeType;
    }

    protected byte _mimeType;
}
