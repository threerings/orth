//
// $Id: MsoyCodes.as 18072 2009-09-11 23:32:26Z ray $

package com.threerings.orth.data {

import com.threerings.presents.data.InvocationCodes;

/**
 * General codes and constants for the whole shebang.
 */
public class OrthCodes extends InvocationCodes
{
    /** Defines our global invocation services group. */
    public static const MSOY_GROUP :String = "msoy";

    /** Defines our world invocation services group. */
    public static const WORLD_GROUP :String = "msoy.world";

    /** Defines our party invocation services group. */
    public static const PARTY_GROUP :String = "msoy.party";

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

    /** Identifies our passport message bundle. */
    public static const PASSPORT_MSGS :String = "passport";

    /** Identifies our party message bundle. */
    public static const PARTY_MSGS :String = "party";

    /** Identifies our studio message bundle. */
    public static const STUDIO_MSGS :String = "studio";

    /** Identifies our home page grid message bundle. */
    public static const HOME_PAGE_GRID_MSGS :String = "homepagegrid";

    /** Identifies our npc message bundle. */
    public static const NPC_MSGS :String = "npc";

    /** Identifies our help message bundle. */
    public static const HELP_MSGS :String = "help";

    /** The maximum length of any name we store in our database tables. */
    public static const MAX_NAME_LENGTH :int = 254; // the db indicates 255, but reality is 254
}
}
