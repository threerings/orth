//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.chat.data;

import com.threerings.presents.data.InvocationCodes;

public interface OrthChatCodes extends InvocationCodes
{
    /** The type of tell messages sent on a {@link SpeakRouter}. */
    public final String TELL_MSG_TYPE = "tellMsg";

    /** The type of speak messages sent on a {@link SpeakRouter}. */
    public final String SPEAK_MSG_TYPE = "speakMsg";

    /** The chat localtype code for messages delivered on the player's current guild object. */
    public final String GUILD_CHAT_TYPE = "guildChat";

    /** The chat localtype code for messages delivered on the player's current party object. */
    public final String PARTY_CHAT_TYPE = "partyChat";

    /** The chat localtype code for messages delivered on a global chat channel. */
    public final String CHANNEL_CHAT_TYPE = "channelChat";

    /** An error code delivered when the user targeted for a tell notification is not online. */
    public final String USER_NOT_ONLINE = "m.user_not_online";
}
