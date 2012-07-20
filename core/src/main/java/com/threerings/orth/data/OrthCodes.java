//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.data;

import com.threerings.presents.data.InvocationCodes;

/**
 * General codes and constants for the entire Orth layer.
 */
public interface OrthCodes extends InvocationCodes
{
    /* Service groups */
    public static final String AETHER_GROUP = "orth.aether";
    public static final String WORLD_GROUP = "orth.world";
    public static final String LOCUS_GROUP = "orth.locus";
    public static final String ROOM_GROUP = "orth.room";

    /** The translation message bundle for our general client bits. */
    public static final String GENERAL_MSGS = "general";

    /** The translation message bundle for our chat messages. */
    public static final String CHAT_MSGS = "chat";

    /** A message even dispatched on the member object to followers. */
    public static final String FOLLOWEE_MOVED = "folMov";

    /** An error code delivered when we're trying to do something to someone we're ignoring. */
    public static final String YOU_IGNORING_PLAYER = "e.you_ignoring_player";

    /** An error code delivered when we're trying to do something to someone we're ignoring. */
    public static final String PLAYER_IGNORING_YOU = "e.player_ignoring_you";
}
