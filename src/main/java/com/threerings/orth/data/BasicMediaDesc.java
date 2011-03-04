//
// $Id: $

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

    protected BasicMediaDesc (byte mimeType, byte constraint)
    {
        _mimeType = mimeType;
        _constraint = constraint;
    }

    public void setConstraint (byte constraint)
    {
        _constraint = constraint;
    }

    public byte getMimeType ()
    {
        return _mimeType;
    }

    public byte getConstraint ()
    {
        return _constraint;
    }

    protected byte _mimeType;
    protected byte _constraint;
}
