//
// $Id$

package com.threerings.orth.world.data;

import com.threerings.presents.dobj.DObject;

/**
 * Implemented by any body that can represent an Orth player's body in an {@link OrthPlace}.
 */
public interface OrthPlayerBody<T extends DObject>
{
    /** Return our implementing object as a {@link DObject}. */
    T self ();

    /** The current location of this body, or null if we're currently in the void. */
    OrthPlace getPlace ();
}
