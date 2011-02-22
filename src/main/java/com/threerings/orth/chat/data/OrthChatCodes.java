//
// $Id$

package com.threerings.orth.chat.data;

import com.threerings.presents.data.InvocationCodes;

public interface OrthChatCodes extends InvocationCodes
{
    /** The type of tell messages sent on a {@link SpeakObject}. */
    public String TELL_MSG_TYPE = "tellMsg";

    /** The type of speak messages sent on a {@link SpeakObject}. */
    public String SPEAK_MSG_TYPE = "speakMsg";

    /** An error code delivered when the user targeted for a tell notification is not online. */
    public static final String USER_NOT_ONLINE = "m.user_not_online";
}
