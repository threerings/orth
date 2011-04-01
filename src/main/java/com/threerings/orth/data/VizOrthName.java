//
// $Id$

package com.threerings.orth.data;

/**
 * An orth name and profile photo all rolled into one!
 */
public abstract class VizOrthName extends OrthName
{
    /** For unserialization. */
    public VizOrthName ()
    {
        super(null, 0);
    }

    /**
     * Creates a new name with the supplied data.
     */
    public VizOrthName (String displayName, int memberId, MediaDesc photo)
    {
        super(displayName, memberId);
        _photo = photo;
    }

    public VizOrthName (OrthName name, MediaDesc photo)
    {
        super(name.toString(), name.getId());
        _photo = photo;
    }

    /**
     * Returns this member's photo.
     */
    public MediaDesc getPhoto ()
    {
        return _photo;
    }

    public abstract MediaDesc getDefaultPhoto ();

    /** This member's profile photo. */
    protected MediaDesc _photo;
}
