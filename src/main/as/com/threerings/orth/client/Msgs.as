//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

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

    /** The world message bundle. */
    public static function get WORLD () :MessageBundle
    {
        return _world;
    }

    /** The chat message bundle. */
    public static function get CHAT () :MessageBundle
    {
        return _chat;
    }

    /** The editing message bundle. */
    public static function get EDITING () :MessageBundle
    {
        return _editing;
    }

    /** The item message bundle. */
    public static function get ITEM () :MessageBundle
    {
        return _item;
    }

    /** The notify message bundle. */
    public static function get NOTIFY () :MessageBundle
    {
        return _notify;
    }

    /** The prefs message bundle. */
    public static function get PREFS () :MessageBundle
    {
        return _prefs;
    }

    /** The party message bundle. */
    public static function get PARTY () :MessageBundle
    {
        return _party;
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
        _world = msgMgr.getBundle(OrthCodes.WORLD_MSGS);
        _chat = msgMgr.getBundle(OrthCodes.CHAT_MSGS);
        _editing = msgMgr.getBundle(OrthCodes.EDITING_MSGS);
        _item = msgMgr.getBundle(OrthCodes.ITEM_MSGS);
        _notify = msgMgr.getBundle(OrthCodes.NOTIFY_MSGS);
        _prefs = msgMgr.getBundle(OrthCodes.PREFS_MSGS);
        _party = msgMgr.getBundle(OrthCodes.PARTY_MSGS);
    }

    protected static var _general :MessageBundle;
    protected static var _world :MessageBundle;
    protected static var _chat :MessageBundle;
    protected static var _editing :MessageBundle;
    protected static var _item :MessageBundle;
    protected static var _notify :MessageBundle;
    protected static var _prefs :MessageBundle;
    protected static var _party :MessageBundle;
}
}
