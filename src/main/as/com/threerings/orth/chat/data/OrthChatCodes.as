//
// $Id$

package com.threerings.orth.chat.data {

import com.threerings.presents.data.InvocationCodes;

public class OrthChatCodes extends InvocationCodes
{
    /** The type of tell messages sent on a {@link SpeakObject}. */
    public static const TELL_MSG_TYPE :String = "tellMsg";

    /** The type of speak messages sent on a {@link SpeakObject}. */
    public static const SPEAK_MSG_TYPE :String = "speakMsg";

    /** An error code delivered when the user targeted for a tell notification is not online. */
    public static const USER_NOT_ONLINE :String = "m.user_not_online";
}
}
