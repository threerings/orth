//
// $Id$

package com.threerings.orth.locus.data;

import com.threerings.io.SimpleStreamableObject;

/**
 * The base type for a specification of a place or guild, used both to instruct the Orth
 * system to host/instantiate the place or guild and for a peer to announce it's hosting it.
 * TODO: better name?
 * TODO: should a party also be a locus? it would seem logical
 */
public abstract class Locus extends SimpleStreamableObject
{
    public abstract int getId ();
}
