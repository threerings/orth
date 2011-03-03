//
// $Id: $

package com.threerings.orth.data;

import com.threerings.io.Streamable;

/**
 * A somewhat more concrete {@link MediaDesc}.
 */
public abstract class BasicMediaDesc extends MediaDescImpl
    implements Streamable
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

    @Override public byte getMimeType ()
    {
        return _mimeType;
    }

    @Override public byte getConstraint ()
    {
        return _constraint;
    }

    protected byte _mimeType;

    protected byte _constraint;
}
