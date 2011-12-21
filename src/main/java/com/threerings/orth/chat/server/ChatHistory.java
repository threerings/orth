//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.chat.server;

import java.util.Collections;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.Set;

import com.google.common.base.Predicate;
import com.google.common.base.Supplier;
import com.google.common.collect.Iterables;
import com.google.common.collect.Lists;

import com.threerings.orth.chat.data.Speak;
import com.threerings.orth.chat.data.Tell;
import com.threerings.orth.data.PlayerName;

import com.google.inject.Singleton;

/**
 * Track the recent chat history of our players,
 */
@Singleton
public class ChatHistory
{
    /** The amount of time before chat history becomes... history. */
    public static final long HISTORY_EXPIRATION = 5L * 60L * 1000L;

    public static class ChatHistoryEntry
    {
        public PlayerName sender;
        public String message;
        public Date timestamp;

        protected ChatHistoryEntry (PlayerName sender, String message, Date timestamp)
        {
            this.sender = sender;
            this.message = message;
            this.timestamp = timestamp;
        }
    }

    public List<ChatHistoryEntry> get (int playerId)
    {
        List<ChatHistoryEntry> history = _history.get(playerId);
        prune(history);
        return history;
    }

    public void file (Tell tell, Date timestamp)
    {
        doFile(tell.getFrom(), Collections.singleton(tell.getTo().getId()),
            tell.getMessage(), timestamp);
    }

    public void file (Speak speak, Set<Integer> recipientIds, Date timestamp)
    {
        doFile(speak.getFrom(), recipientIds, speak.getMessage(), timestamp);
    }

    public void clear (int playerId)
    {
        _history.remove(playerId);
    }

    protected void doFile (PlayerName sender, Set<Integer> recipientIds, String msg, Date stamp)
    {
        for (int recipientId : recipientIds) {
            List<ChatHistoryEntry> entries = _history.get(recipientId);
            addEntry(entries, new ChatHistoryEntry(sender, msg, stamp));
        }
    }

    protected void addEntry (List<ChatHistoryEntry> history, ChatHistoryEntry entry)
    {
        history.add(entry);

        // if the history is big enough, potentially prune it (we always prune when asked for
        // the history, so this is just to balance memory usage with CPU expense)
        if (history.size() > 15) {
            prune(history);
        }
    }

    /**
     * Prunes all messages from this history which are expired.
     */
    protected List<ChatHistoryEntry> prune (List<ChatHistoryEntry> history)
    {
        final long now = System.currentTimeMillis();
        Iterables.removeIf(history, new Predicate<ChatHistoryEntry>() {
            @Override public boolean apply (ChatHistoryEntry entry) {
                return now - entry.timestamp.getTime() > HISTORY_EXPIRATION;
            }
        });
    }

    protected final Map<Integer, List<ChatHistoryEntry>> _history =
        ComputingMap.create(new Supplier<List<ChatHistoryEntry>>() {
            @Override public List<ChatHistoryEntry> get () {
                return Lists.newArrayList();
            }
        });
}
