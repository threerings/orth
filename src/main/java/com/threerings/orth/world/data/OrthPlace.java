//
// $Id$

package com.threerings.orth.world.data;

/**
 * The base type for a location that an Orth player can be in. Although there is no way to
 * enforce it in this interface, implementors must also write proper equals()/hashCode().
 */
public interface OrthPlace
{
    /** The peer this place is hosted on. */
    public String getPeer ();

    /** A short, human-readable description of what place this is. */
    public String describePlace ();
}
