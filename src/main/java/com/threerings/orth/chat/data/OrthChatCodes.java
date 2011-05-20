//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.chat.data;

import com.threerings.presents.data.InvocationCodes;

public interface OrthChatCodes extends InvocationCodes
{
    /** The type of tell messages sent on a {@link SpeakRouter}. */
    public String TELL_MSG_TYPE = "tellMsg";

    /** The type of speak messages sent on a {@link SpeakRouter}. */
    public String SPEAK_MSG_TYPE = "speakMsg";

    /** An error code delivered when the user targeted for a tell notification is not online. */
    public static final String USER_NOT_ONLINE = "m.user_not_online";
}
