//
// $Id$

package com.threerings.orth.data;

import com.threerings.io.SimpleStreamableObject;

import com.threerings.orth.data.MediaDesc;

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
