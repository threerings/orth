//
// $Id$

package com.threerings.orth.world.data;

import com.threerings.io.Streamable;

/**
 * Somewhere you can move; always includes a {@link PlaceKey}, and any other information which
 * is opaque to us but to be interpreted by the specific place implementation; a typical use
 * would be the location within the place at which to arrive.
 */
public interface Destination extends Streamable
{
    PlaceKey getPlaceKey ();
}
