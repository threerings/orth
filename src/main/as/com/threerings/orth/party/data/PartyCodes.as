//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.party.data {

/**
 * Party constants.
 */
public class PartyCodes
{
    /** The maximum length of a party name. */
    public static const MAX_NAME_LENGTH :int = 32;

    public static const GAME_STATE_NONE :int = 0;
    public static const GAME_STATE_AVRG :int = 1;
    public static const GAME_STATE_LOBBY :int = 2;
    public static const GAME_STATE_INGAME :int = 3;

    public static const STATUS_TYPE_USER :int = 0;
    public static const STATUS_TYPE_SCENE :int = 1;
    public static const STATUS_TYPE_PLAYING :int = 2;
    public static const STATUS_TYPE_LOBBY :int = 3;
}
}
