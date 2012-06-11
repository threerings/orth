//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.party.data;

/**
 * Party constants.
 */
public class PartyCodes
{
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

    /** The maximum size of a party. */
    public static final int MAX_PARTY_SIZE = 50;

    /** Error codes. */
    public static final String E_PARTY_FULL = "e.party_full";
    public static final String E_ALREADY_IN_PARTY = "e.already_in_party";
    public static final String E_CANT_INVITE_CLOSED = "e.cant_invite_closed";
}
