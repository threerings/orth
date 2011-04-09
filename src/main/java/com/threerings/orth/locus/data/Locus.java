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
//CWG-JD - I lied when writing the above comment; it's not necessary that a Locus be used to
//announce that a peer is hosting it. For intervention locii, there's no reason to publish their
//hosting as no other peer should need to look them up; the only way to access an intervention is
//through a person in that intervention who has the whole address already. As such, I don't think it
//makes sense for Locii to be a Nodelets. Locii just describe a location, they don't need to be
//published.
//
//I don't understand the party TODO above. Why would a party be a locus? It's not a location.
//It definitely makes sense to make it a Nodelet.
public abstract class Locus extends Nodelet
{
}
