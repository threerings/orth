//
// $Id$

package com.threerings.orth.locus.data;

import com.threerings.orth.nodelet.data.Nodelet;

/**
 * The base type for a specification of a place, used both to instruct the Orth system to
 * host/instantiate the place and for a peer to announce it's hosting it.
 * TODO: better name?
 * TODO: should a party also be a locus? it would seem logical
 */
public abstract class Locus extends Nodelet
{
}
