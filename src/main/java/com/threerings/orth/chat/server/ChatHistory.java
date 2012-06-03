//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.chat.server;

import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.Set;

import com.google.common.base.Predicate;
import com.google.common.base.Supplier;
import com.google.common.collect.ImmutableSet;
import com.google.common.collect.Iterables;
import com.google.common.collect.Lists;
import com.google.inject.Inject;
import com.google.inject.Singleton;

import com.samskivert.util.Comparators;
import com.samskivert.util.ResultListener;

import com.threerings.io.SimpleStreamableObject;

import com.threerings.presents.annotation.AnyThread;
import com.threerings.presents.client.InvocationService;
import com.threerings.presents.peer.data.NodeObject;
import com.threerings.presents.peer.server.NodeRequestsListener;
import com.threerings.presents.peer.server.PeerManager;
import com.threerings.presents.server.InvocationException;

import com.threerings.orth.aether.server.IgnoreManager;
import com.threerings.orth.chat.data.Speak;
import com.threerings.orth.chat.data.Tell;
import com.threerings.orth.data.PlayerName;
import com.threerings.orth.util.ComputingMap;

import static com.threerings.orth.Log.log;

/**
 * Track the recent chat history of our players,
 */
@Singleton
public class ChatHistory
{
    /** The amount of time before chat history becomes... history. */
    public static final long HISTORY_EXPIRATION = 10L * 60L * 1000L;

    public static class ChatHistoryEntry extends SimpleStreamableObject
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

    /**
     * Value asynchronously returned by {@link #collectChatHistory} after polling all peer nodes.
     */
    public static class ChatHistoryResult extends SimpleStreamableObject
    {
        /** The set of nodes that either did not reply within the timeout, or had a failure. */
        public Set<String> failedNodes;

        /** The things in the user's chat history, aggregated from all nodes and sorted by
         * timestamp. */
        public List<ChatHistoryEntry> history;
    }

    public List<ChatHistoryEntry> get (int playerId)
    {
        List<ChatHistoryEntry> history = _history.get(playerId);
        prune(history);
        return history;
    }

    public void file (Tell tell, Date timestamp)
    {
        // make sure this ends up in the tell history both of sender and recipient
        doFile(tell.getFrom(), ImmutableSet.of(tell.getFrom().getId(), tell.getTo().getId()),
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
        int senderId = sender.getId();
        for (int recipientId : recipientIds) {
            // don't file what we recipient won't actually see
            if (_ignoreMan.isIgnoring(recipientId, senderId)) {
                continue;
            }
            List<ChatHistoryEntry> entries = _history.get(recipientId);
            addEntry(entries, new ChatHistoryEntry(sender, msg, stamp));
        }
    }

    /**
     * Collects all chat messages heard by the given user on all peers.
     */
    @AnyThread
    public void collectChatHistory (
        final int playerId, final ResultListener<ChatHistoryResult> lner)
    {
        _peerMan.invokeNodeRequest(new PeerManager.NodeRequest() {
            public boolean isApplicable (NodeObject nodeobj) {
                return true; // poll all nodes
            }
            @Override protected void execute (InvocationService.ResultListener listener) {
                // find all the UserMessages for the given user and send them back
                listener.requestProcessed(Lists.newArrayList(_chatHistory.get(playerId)));
            }
            @Inject protected transient ChatHistory _chatHistory;
        }, new NodeRequestsListener<List<ChatHistoryEntry>>() {
            public void requestsProcessed (NodeRequestsResult<List<ChatHistoryEntry>> rRes) {
                ChatHistoryResult chRes = new ChatHistoryResult();
                chRes.failedNodes = rRes.getNodeErrors().keySet();
                chRes.history = Lists.newArrayList(
                    Iterables.concat(rRes.getNodeResults().values()));
                Collections.sort(chRes.history, SORT_BY_TIMESTAMP);
                lner.requestCompleted(chRes);
            }
            public void requestFailed (String cause) {
                log.warning("collectChatHistory failed", "playerId", playerId, cause);
                lner.requestFailed(new InvocationException(cause));
            }
        });
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
    protected void prune (List<ChatHistoryEntry> history)
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

    @Inject protected IgnoreManager _ignoreMan;
    @Inject protected PeerManager _peerMan;

    protected static final Comparator<ChatHistoryEntry> SORT_BY_TIMESTAMP =
        new Comparator<ChatHistoryEntry>() {
            public int compare (ChatHistoryEntry e1, ChatHistoryEntry e2) {
                return Comparators.compare(e1.timestamp.getTime(), e2.timestamp.getTime());
            }
        };
}
