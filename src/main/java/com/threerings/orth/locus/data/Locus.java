//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.
package com.threerings.orth.locus.data;

import com.threerings.orth.nodelet.data.Nodelet;

/**
 * The base type for a specification of a place, used both to instruct the Orth system to
 * host/instantiate the place and for a peer to announce it's hosting it.
 */
//CWG-JD - I lied when writing the above comment; it's not necessary that a Locus be used to
//announce that a peer is hosting it. For intervention locii, there's no reason to publish their
//hosting as no other peer should need to look them up; the only way to access an intervention is
//through a person in that intervention who has the whole address already. As such, I don't think it
//makes sense for Locii to be a Nodelets. Locii just describe a location, they don't need to be
//published.
//JD-CWG Fuck, I spent a lot time trying to isolate the locus code in NodeletHoster. I'd like to
//think about some way to remove the intervention publishing without removing the Nodelet
//inheritance. My eventual ambition with this is to eliminate a lot of the presents boiler plate:
//the twelvety classes that are required to set up a new kind of connection. For example,
//GuildRegistry gets a ton of stuff for free and I think this could extend to benefit scene,
//intervention and party as well as future data hosting connections that come up.
public abstract class Locus extends Nodelet
{
}
