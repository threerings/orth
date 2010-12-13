//
// $Id$

package com.threerings.orth.party.data;

/**
 * Party constants.
 */
public class PartyCodes
{
    /** Recruitment constant indicating anyone may join the party. */
    public static final byte RECRUITMENT_OPEN = 0;

    /** Recruitment constant indicating that only members of the party's group may join. */
    public static final byte RECRUITMENT_GROUP = 1;

    /** Recruitment constant indicating nobody but those invited by the leader may join. */
    public static final byte RECRUITMENT_CLOSED = 2;

    /** The maximum length of a party name. */
    public static final int MAX_NAME_LENGTH = 32;

    public static final byte GAME_STATE_NONE = 0;
    public static final byte GAME_STATE_AVRG = 1;
    public static final byte GAME_STATE_LOBBY = 2;
    public static final byte GAME_STATE_INGAME = 3;

    public static final byte STATUS_TYPE_USER = 0;
    public static final byte STATUS_TYPE_SCENE = 1;
    public static final byte STATUS_TYPE_PLAYING = 2;
    public static final byte STATUS_TYPE_LOBBY = 3;

    /** Board mode for a normal party board. */
    public static final byte BOARD_NORMAL = 0;
    /** Board mode for a normal party board. */
    public static final byte BOARD_AWAITING_PLAYERS = 1;
    /** Board mode for a party board showing all friends, even when not leading. */
    public static final byte BOARD_FRIENDS = 2;

    /** The maximum size of a party. */
    public static final int MAX_PARTY_SIZE = 50;

    /** Error codes. */
    public static final String E_NO_SUCH_PARTY = "e.no_such_party";
    public static final String E_PARTY_FULL = "e.party_full";
    public static final String E_PARTY_CLOSED = "e.party_closed";
    public static final String E_ALREADY_IN_PARTY = "e.already_in_party";
    public static final String E_GROUP_MGR_REQUIRED = "e.group_mgr_req";
    public static final String E_CANT_INVITE_CLOSED = "e.cant_invite_closed";
}
