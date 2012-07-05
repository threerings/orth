//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.aether.server;

import java.util.List;
import java.util.Map;

import com.google.common.collect.Lists;
import com.google.inject.Inject;
import com.google.inject.Injector;
import com.google.inject.Singleton;

import com.samskivert.util.Invoker;

import com.threerings.util.Resulting;

import com.threerings.presents.annotation.BlockingThread;
import com.threerings.presents.annotation.MainInvoker;
import com.threerings.presents.client.InvocationService.InvocationListener;
import com.threerings.presents.data.InvocationCodes;
import com.threerings.presents.server.InvocationException;
import com.threerings.presents.server.InvocationManager;

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
public class IgnoreManager implements IgnoreProvider
{
    @Inject public IgnoreManager (Injector injector)
    {
        // register our bootstrap invocation service
        injector.getInstance(InvocationManager.class).registerProvider(
            this, IgnoreMarshaller.class, OrthCodes.AETHER_GROUP);
    }

    /**
     * Test to see if one player is ignoring another. This method can be called from any peer,
     * including e.g. party or guild nodelets, because it uses data broadcast across the network.
     */
    public boolean isIgnoring (int ignorerId, int ignoreeId)
    {
        return _peerMgr.isIgnoring(ignorerId, ignoreeId);
    }

    /**
     * Ensure that neither of the given players is ignoring the others, and if they are, throw
     * an appropriate InvocationException.
     */
    public void validateCommunication (int inviterId, int inviteeId)
        throws InvocationException
    {
        // if sender is ignoring recipient, protest
        if (_peerMgr.isIgnoring(inviterId, inviteeId)) {
            throw new InvocationException(OrthCodes.YOU_IGNORING_PLAYER);
        }
        // if recipient is ignoring caller, silently drop the request
        if (_peerMgr.isIgnoring(inviteeId, inviterId)) {
            throw new InvocationException(OrthCodes.PLAYER_IGNORING_YOU);
        }
    }

    /**
     * Initializes the ignore list from persistent store.
     */
    @BlockingThread
    public List<PlayerName> resolveIgnoringList (int ignorerId)
    {
        Map<Integer, String> names = _playerRepo.resolvePlayerNames(
            _relationRepo.getIgnoreeIds(ignorerId));

        List<PlayerName> list = Lists.newArrayList();
        for (Map.Entry<Integer, String> pair : names.entrySet()) {
            list.add(new PlayerName(pair.getValue(), pair.getKey()));
        }
        return list;
    }

    /**
     * Initializes the ignore list from persistent store.
     */
    @BlockingThread
    public List<PlayerName> resolveIgnoredByList (int ignorerId)
    {
        Map<Integer, String> names = _playerRepo.resolvePlayerNames(
            _relationRepo.getIgnorerIds(ignorerId));

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
                    updateIgnoring(caller, name, true);
                } else {
                    updateIgnoring(caller, name, false);
                }
            }
        });
    }

    protected void updateIgnoring (
        final AetherClientObject caller, final PlayerName ignoree, final boolean doAdd)
    {
        // ignoring happens on the ignorer's vault peer, so we can do this the easy way
        if (doAdd) {
            caller.addToIgnoring(ignoree);
        } else {
            caller.removeFromIgnoring(ignoree.getKey());
        }

        // updating the reverse mapping may well need a peer hop, though
        _peerMgr.invokeNodeAction(new AetherNodeAction(ignoree.getId()) {
            @Override protected void execute (AetherClientObject player) {
                if (doAdd) {
                    player.addToIgnoredBy(caller.playerName);
                } else {
                    player.removeFromIgnoredBy(caller.playerName);
                }
            }
        });

        _peerMgr.noteIgnoring(caller.getPlayerId(), ignoree.getId(), doAdd);
    }

    // dependencies
    @Inject protected OrthPeerManager _peerMgr;
    @Inject protected PlayerRepository _playerRepo;
    @Inject protected RelationshipRepository _relationRepo;
    @Inject protected @MainInvoker Invoker _invoker;
}
