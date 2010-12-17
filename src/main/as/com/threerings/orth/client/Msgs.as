//
// $Id$

package com.threerings.orth.client {

import com.threerings.util.MessageBundle;
import com.threerings.util.MessageManager;

import com.threerings.orth.data.OrthCodes;

/**
 * Handy class for easily getting message bundles on the client.
 */
public class Msgs
{
    /** The general message bundle. */
    public static function get GENERAL () :MessageBundle
    {
        return _general;
    }

    /** The chat message bundle. */
    public static function get CHAT () :MessageBundle
    {
        return _chat;
    }

    /**
     * Initialize the bundles.
     */
    public static function init (msgMgr :MessageManager) :void
    {
        if (_general) {
            return;
        }

        _general = msgMgr.getBundle(OrthCodes.GENERAL_MSGS);
        _chat = msgMgr.getBundle(OrthCodes.CHAT_MSGS);
    }

    protected static var _general :MessageBundle;
    protected static var _chat :MessageBundle;
}
}
