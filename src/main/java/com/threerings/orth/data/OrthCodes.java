//
// $Id: $

package com.threerings.orth.data;

import com.threerings.presents.data.InvocationCodes;

/**
 * General codes and constants for the entire Orth layer.
 */
public interface OrthCodes extends InvocationCodes
{
    /** Defines our aether invocation services group. */
    public static final String AETHER_GROUP = "orth.aether";

    /** Defines our world invocation services group. */
    public static final String WORLD_GROUP = "orth.world";

    /** Defines our room invocation services group. */
    public static final String ROOM_GROUP = "orth.room";

    /** The translation message bundle for our general client bits. */
    public static final String GENERAL_MSGS = "general";

    /** The translation message bundle for our chat messages. */
    public static final String CHAT_MSGS = "chat";

}
