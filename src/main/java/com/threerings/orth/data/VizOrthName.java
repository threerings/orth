//
// $Id: VizMemberName.java 19625 2010-11-24 15:47:54Z zell $

package com.threerings.orth.data;

/**
 * An orth name and profile photo all rolled into one!
 */
public abstract class VizOrthName extends OrthName
{
    /** For unserialization. */
    public VizOrthName ()
    {
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