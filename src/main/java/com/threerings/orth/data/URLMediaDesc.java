//
// $Id: $

package com.threerings.orth.data;


/**
 * A trivial MediaDesc implementation that is configured with an explicit URL.
 */
public class URLMediaDesc extends BasicMediaDesc
    implements ClientMediaDesc
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

    @Override // from Object
    public int hashCode ()
    {
        return (getMimeType() * 43 + getConstraint()) * 43 ^ getMediaPath().hashCode();
    }

	@Override // from Object
	public boolean equals (Object other)
	{
		return (other instanceof URLMediaDesc) &&
			(getMimeType() == ((URLMediaDesc) other).getMimeType()) &&
            (getConstraint() == ((URLMediaDesc) other).getConstraint()) &&
            (getMediaPath().equals(((URLMediaDesc) other).getMediaPath()));

	}

    protected String _url;
}

