//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.chat.client {

import com.threerings.util.Log;

import com.threerings.crowd.chat.client.ChatDisplay;
import com.threerings.crowd.chat.data.ChatMessage;

/**
 * Maintains chat history.
 */
public class HistoryList
    implements ChatDisplay
{
    public function HistoryList (dir :OrthChatDirector)
    {
        _chatDir = dir;
    }

    /**
     * @return the current size of the history.
     */
    public function size () :int
    {
        return _history.length;
    }

    /**
     * Get the history entry at the specified index.
     */
    public function get (index :int) :ChatMessage
    {
        return (_history[index] as ChatMessage);
    }

    public function clearAll () :void
    {
        _history.length = 0;
    }

    // from interface ChatDisplay
    public function clear () :void
    {
        var selectedType :String = _chatDir.getCurrentLocalType();
        _history = _history.filter(function (msg :ChatMessage, ... ignored) :Boolean {
            return (msg.localtype != selectedType);
        });
    }

    // from interface ChatDisplay
    public function displayMessage (msg :ChatMessage) :void
    {
        if (_history.length == MAX_HISTORY) {
            _history.splice(0, PRUNE_HISTORY);
        }
        _history.push(msg);
    }

    private const log :Log = Log.getLog(this);

    /** The maximum number of history entries we'll keep. */
    protected static const MAX_HISTORY :int = 1000;

    /** The number of history entries we'll prune when we hit the max. */
    protected static const PRUNE_HISTORY :int = 100;

    /** The array in which we store historical chat. */
    protected var _history :Array = [];

    protected var _chatDir :OrthChatDirector;
}
}
