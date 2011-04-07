//
// $Id$

package com.threerings.orth.nodelet.data;

import com.threerings.io.SimpleStreamableObject;

/**
 * The base type for an object that is subscribed to simultaneously by multiple players and is
 * hosted on a single server, which each subscriber must connect to. The nodelet is used to
 * instantiate the shared {@code DObject} that players will subscribe to as well as to publish
 * the hosting state.
 */
public abstract class Nodelet extends SimpleStreamableObject
{
    /** The unique integer identifying this nodelet. Note the ids are only unique within the
     * scope of the concrete implementing type. */
    public abstract int getId ();
}
