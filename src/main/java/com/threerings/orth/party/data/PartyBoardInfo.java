//
// $Id$

package com.threerings.orth.party.data;

import com.samskivert.util.RandomUtil;

import com.threerings.io.SimpleStreamableObject;

import com.threerings.orth.aether.data.PlayerObject;

/**
 * Contains general info about a party for the party board.
 */
public class PartyBoardInfo extends SimpleStreamableObject
    implements Comparable<PartyBoardInfo> // server only
{
    /** The immutable info. */
    public PartySummary summary;

    /** The mutable info. */
    public PartyInfo info;

    /** Mister Unserializable. */
    public PartyBoardInfo ()
    {
    }

    public PartyBoardInfo (PartySummary summary, PartyInfo info)
    {
        this.summary = summary;
        this.info = info;
    }

    /**
     * Compute the score for this party (server only).
     */
    public void computeScore (PlayerObject player)
    {
        // start by giving every party a random score between 0 and 1
        float score = RandomUtil.rand.nextFloat();
        // add 3 if their friend is leading the party
        if (player.isOnlineFriend(info.leaderId)) {
            score += 3;
        }
        // now, each party is in a "band" determined by friend, and then has a random
        // position within that band.
        _score = score;
    }

    // from Comparable
    public int compareTo (PartyBoardInfo that)
    {
        return Float.compare(that._score, this._score); // order is reversed- higher scores at top
    }

    /** A calculated score for comparison purposes, only used on the server. */
    protected transient float _score;
}
