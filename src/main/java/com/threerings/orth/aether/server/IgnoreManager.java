//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.aether.server;

import java.util.Collection;
import java.util.List;
import java.util.Map;

import com.google.common.collect.HashMultimap;
import com.google.common.collect.Lists;
import com.google.common.collect.Multimap;
import com.google.inject.Inject;
import com.google.inject.Injector;
import com.google.inject.Singleton;

import com.samskivert.util.Invoker;
import com.samskivert.util.Lifecycle;

import com.threerings.util.Resulting;

import com.threerings.presents.annotation.BlockingThread;
import com.threerings.presents.annotation.MainInvoker;
import com.threerings.presents.client.InvocationService.InvocationListener;
import com.threerings.presents.data.InvocationCodes;
import com.threerings.presents.server.InvocationException;
import com.threerings.presents.server.InvocationManager;
import com.threerings.presents.server.PresentsSession;

import com.threerings.orth.aether.data.AetherClientObject;
import com.threerings.orth.aether.data.IgnoreMarshaller;
import com.threerings.orth.aether.server.persist.RelationshipRepository;
import com.threerings.orth.data.OrthCodes;
import com.threerings.orth.data.PlayerName;
import com.threerings.orth.peer.server.OrthPeerManager;
import com.threerings.orth.server.persist.PlayerRepository;

import static com.threerings.orth.Log.log;

/**
 * Manages {@link AetherClientObject#ignoring} and ignore-related request for the local server.
 */
@Singleton
public class IgnoreManager implements Lifecycle.InitComponent, IgnoreProvider
{
    @Inject public IgnoreManager (Injector injector)
    {
        injector.getInstance(Lifecycle.class).addComponent(this);

        // register our bootstrap invocation service
        injector.getInstance(InvocationManager.class).registerProvider(
            this, IgnoreMarshaller.class, OrthCodes.AETHER_GROUP);
    }

    @Override
    public void init ()
    {
        _locator.addObserver(new AetherSessionLocator.Observer() {
            @Override public void playerLoggedIn (PresentsSession session, AetherClientObject plobj) {
                initReverseMapping(plobj);
            }
            @Override public void playerWillLogout (PresentsSession session, AetherClientObject plobj) {
                clearReverseMapping(plobj);
            }
        });
    }

    /**
     * Determine whether one person is ignored by another. NOTE: This class only keeps track of
     * ignorers of currently-online players, though the ignorers themselves may be offline.
     */
    public boolean isIgnoredBy (int ignoreeId, int ignorerId)
    {
        return _ignoredBy.containsEntry(ignoreeId, ignorerId);
    }

    public void validateCommunication (int inviterId, int inviteeId)
        throws InvocationException
    {
        // if sender is ignoring recipient, protest
        if (isIgnoredBy(inviteeId, inviterId)) {
            throw new InvocationException(OrthCodes.YOU_IGNORING_PLAYER);
        }
        // if recipient is ignoring caller, silently drop the request
        if (isIgnoredBy(inviterId, inviteeId)) {
            throw new InvocationException(OrthCodes.PLAYER_IGNORING_YOU);
        }
    }

    /**
     * Initializes the ignore list from persistent store.
     */
    @BlockingThread
    public List<PlayerName> resolveIgnoreList (int ignorerId)
    {
        Map<Integer, String> names = _playerRepo.resolvePlayerNames(
            _relationRepo.getIgnoreeIds(ignorerId));

        List<PlayerName> list = Lists.newArrayList();
        for (Map.Entry<Integer, String> pair : names.entrySet()) {
            list.add(new PlayerName(pair.getValue(), pair.getKey()));
        }
        return list;
    }

    @Override public void ignorePlayer (final AetherClientObject caller, final int ignoreeId,
        final boolean doIgnore, InvocationListener listener)
        throws InvocationException
    {
        final int ignorerId = caller.getPlayerId();

        if (caller.ignoring.containsKey(ignoreeId) == doIgnore) {
            // already in the requested state
            log.warning("Nothing to do in ignorePlayer", "caller", caller.who(),
                "ignoreeId", ignoreeId, "doIgnore", doIgnore);
            return;
        }

        if (caller.friends.containsKey(ignoreeId)) {
            log.warning("Refusing to ignore a friend", "caller", caller.who(),
                "ignoreeId", ignoreeId);
            throw new InvocationException(InvocationCodes.E_INTERNAL_ERROR);
        }

        _invoker.postUnit(new Resulting<PlayerName>("Ignore player", listener) {
            @Override public PlayerName invokePersist () throws Exception {
                if (doIgnore) {
                    _relationRepo.ignorePlayer(ignorerId, ignoreeId);
                    String name = _playerRepo.resolvePlayerName(ignoreeId);
                    return (name != null) ? new PlayerName(name, ignoreeId) : null;
                }
                _relationRepo.unignorePlayer(ignorerId, ignoreeId);
                return null;
            }

            @Override public void requestCompleted (PlayerName name) {
                if (doIgnore) {
                    if (name == null) {
                        log.info("Can't ignore nameless player", "caller", caller.who(),
                            "ignoreeId", ignoreeId);
                        return;
                    }
                    caller.addToIgnored(name);
                    _ignoredBy.put(ignoreeId, ignorerId);

                } else {
                    caller.removeFromIgnored(ignoreeId);
                    _ignoredBy.remove(ignoreeId, ignorerId);
                }
            }
        });
    }

    /**
     * Find all the players who are currently ignoring us.
     */
    protected void initReverseMapping (AetherClientObject plobj)
    {
        final int ignoreeId = plobj.getPlayerId();
        _invoker.postUnit(new Resulting<Collection<Integer>>("initReverseMapping") {
            @Override public Collection<Integer> invokePersist () throws Exception {
                return _relationRepo.getIgnorerIds(ignoreeId);
            }
            @Override public void requestCompleted (Collection<Integer> ignorers) {
                for (int ignorerId : ignorers) {
                    _ignoredBy.put(ignoreeId, ignorerId);
                }
            }
        });
    }

    /**
     * Forget who's ignoring us. We don't care.
     */
    protected void clearReverseMapping (AetherClientObject plobj)
    {
        _ignoredBy.removeAll(plobj.getPlayerId());
    }

    final protected Multimap<Integer, Integer> _ignoredBy = HashMultimap.create();

    // dependencies
    @Inject protected AetherSessionLocator _locator;
    @Inject protected OrthPeerManager _peerMgr;
    @Inject protected PlayerRepository _playerRepo;
    @Inject protected RelationshipRepository _relationRepo;
    @Inject protected @MainInvoker Invoker _invoker;
}
