//
// $Id: $

package com.threerings.orth.data;

/**
 * A trivial MediaDesc implementation that is configured with an explicit URL.
 */
public class URLMediaDesc extends BasicMediaDesc
{
    public URLMediaDesc ()
    {
    }

    public URLMediaDesc (String URL, byte mimeType, byte constraint)
    {
        super(mimeType, constraint);
        _url = URL;
    }

    // from MediaDesc
    @Override public String getMediaPath ()
    {
        return _url;
    }

    @Override public URLMediaDesc newWithConstraint (byte constraint)
    {
        return new URLMediaDesc(_url, _mimeType, constraint);
    }

    protected String _url;
}

