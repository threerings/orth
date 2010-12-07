//
// $Id: PlayerObject.as 19627 2010-11-24 16:02:41Z zell $

package com.threerings.orth.data {

import com.threerings.presents.dobj.DSet;

import com.threerings.crowd.data.TokenRing;

import com.threerings.io.ObjectInputStream;

import com.threerings.util.Name;

import com.threerings.orth.room.data.ActorObject;
import com.threerings.orth.room.data.EntityIdent;

import com.threerings.orth.data.OrthName;
import com.threerings.orth.data.PlayerEntry;

/**
 * Represents a connected orth user.
 */
public class PlayerObject extends ActorObject
{
    /** The field name of the <code>playerName</code> field. */
    public static const PLAYER_NAME :String = "playerName";

    /** The field name of the <code>following</code> field. */
    public static const FOLLOWING :String = "following";

    /** The field name of the <code>followers</code> field. */
    public static const FOLLOWERS :String = "followers";

    /** The field name of the <code>avatar</code> field. */
    public static const AVATAR :String = "avatar";

    /** The field name of the <code>friends</code> field. */
    public static const FRIENDS :String = "friends";

    /** The field name of the <code>walkingId</code> field. */
    public static const WALKING_ID :String = "walkingId";

    /** The field name of the <code>partyId</code> field. */
    public static const PARTY_ID :String = "partyId";

    /** A message sent by the server to denote a notification to be displayed.
     * Format: [ Notification ]. */
    public static const NOTIFICATION :String = "notification";

    /** The member name and id for this user. */
    public var playerName :VizOrthName;

    /** The name of the member this member is following or null. */
    public var following :OrthName;

    /** The names of members following this member. */
    public var followers :DSet;

    /** The avatar that the user has chosen, or null for guests. */
    public var avatar :EntityIdent;

    /** The online friends of this player. */
    public var friends :DSet;

    /** If this member is currently walking a pet, the id of the pet being walked, else 0. */
    public var walkingId :int;

    /** The player's current partyId, or 0 if they're not in a party. */
    public var partyId :int;

    /**
     * Return this member's unique id.
     */
    public function getPlayerId () :int
    {
        return playerName.getId();
    }

    /**
     * Returns true if this member is away.
     */
    public function isAway () :Boolean
    {
        return (awayMessage != null);
    }

    /**
     * Get a sorted list of friends.
     */
    public function getSortedFriends () :Array
    {
        return friends.toArray().sort(PlayerEntry.sortByName);
    }

    override public function getVisibleName () :Name
    {
        return playerName;
    }

    /**
     * Convenience.
     */
    public function isOnlineFriend (memberId :int) :Boolean
    {
        return friends.containsKey(memberId);
    }

    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);

        playerName = VizOrthName(ins.readObject());
        following = OrthName(ins.readObject());
        followers = DSet(ins.readObject());
        avatar = EntityIdent(ins.readObject());
        friends = DSet(ins.readObject());
        walkingId = ins.readInt();
        partyId = ins.readInt();
    }
}
}
