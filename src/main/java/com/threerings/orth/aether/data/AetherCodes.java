package com.threerings.orth.aether.data;

import com.threerings.presents.data.InvocationCodes;

public interface AetherCodes extends InvocationCodes
{
    /** An error code delivered when the user targeted for a friend request is not online. */
    public static final String USER_NOT_ONLINE = "m.user_not_online";

    /** An error code delivered when a friend request is already pending. */
    public static final String FRIEND_REQUEST_ALREADY_SENT = "m.request_already_sent";
}
