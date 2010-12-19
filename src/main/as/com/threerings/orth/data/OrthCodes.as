//
// $Id: $

package com.threerings.orth.data {

import com.threerings.presents.data.InvocationCodes;

/**
 * General codes and constants for the entire Orth layer.
 */
public class OrthCodes extends InvocationCodes
{
    public static const AETHER_GROUP :String = "orth.aether";

    /** Identifies our general message bundle. */
    public static const GENERAL_MSGS :String = "general";

    /** Identifies our world message bundle. */
    public static const WORLD_MSGS :String = "world";

    /** Identifies our chat message bundle. */
    public static const CHAT_MSGS :String = "chat";

    /** Identifies our item message bundle. */
    public static const ITEM_MSGS :String = "item";

    /** Identifies our prefs message bundle. */
    public static const PREFS_MSGS :String = "prefs";

    /** Identifies our notification message bundle. */
    public static const NOTIFY_MSGS :String = "notify";

    /** Identifies our editing message bundle. */
    public static const EDITING_MSGS :String = "editing";

    /** Identifies our party message bundle. */
    public static const PARTY_MSGS :String = "party";

    /** Identifies our npc message bundle. */
    public static const NPC_MSGS :String = "npc";

    /** Identifies our help message bundle. */
    public static const HELP_MSGS :String = "help";

    /** The maximum length of any name we store in our database tables. */
    public static const MAX_NAME_LENGTH :int = 254; // the db indicates 255, but reality is 254
}
}
