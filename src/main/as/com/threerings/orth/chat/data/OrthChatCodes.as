//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.chat.data {

import com.threerings.presents.data.InvocationCodes;

public class OrthChatCodes extends InvocationCodes
{
    /** The type of speak messages sent on a {@link SpeakObject}. */
    public static const SPEAK_MSG_TYPE :String = "speakMsg";

    /** An error code delivered when the user targeted for a tell notification is not online. */
    public static const USER_NOT_ONLINE :String = "m.user_not_online";

    /** The chat localtype code for messages delivered on the player's current guild object. */
    public static const GUILD_CHAT_TYPE :String = "guildChat";
}
}
