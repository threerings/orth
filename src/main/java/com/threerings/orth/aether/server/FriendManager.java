//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.aether.server;

import java.util.List;
import java.util.Map;
import java.util.Set;

import com.google.common.collect.HashMultimap;
import com.google.common.collect.Lists;
import com.google.common.collect.SetMultimap;
import com.google.common.collect.Sets;
import com.google.inject.Inject;
import com.google.inject.Injector;
import com.google.inject.Singleton;

import com.samskivert.util.Invoker;
import com.samskivert.util.Lifecycle;

import com.threerings.util.Resulting;

import com.threerings.presents.annotation.MainInvoker;
import com.threerings.presents.client.InvocationService.InvocationListener;
import com.threerings.presents.client.InvocationService.ResultListener;
import com.threerings.presents.dobj.DSet;
import com.threerings.presents.peer.server.NodeRequestsListener;
import com.threerings.presents.server.InvocationException;
import com.threerings.presents.server.InvocationManager;
import com.threerings.presents.server.PresentsSession;

import com.threerings.orth.aether.data.AetherAuthName;
import com.threerings.orth.aether.data.AetherClientObject;
import com.threerings.orth.aether.data.AetherCodes;
import com.threerings.orth.aether.data.FriendMarshaller;
import com.threerings.orth.aether.data.FriendshipAcceptance;
import com.threerings.orth.aether.data.FriendshipRequest;
import com.threerings.orth.aether.data.FriendshipTermination;
import com.threerings.orth.aether.data.PeeredPlayerInfo;
import com.threerings.orth.aether.server.persist.RelationshipRepository;
import com.threerings.orth.comms.data.CommSender;
import com.threerings.orth.data.FriendEntry;
import com.threerings.orth.data.OrthCodes;
import com.threerings.orth.data.PlayerName;
import com.threerings.orth.data.where.Whereabouts;
import com.threerings.orth.peer.server.OrthPeerManager;
import com.threerings.orth.server.persist.PlayerRepository;
import com.threerings.orth.server.util.InviteThrottle;

import com.threerings.signals.Listener1;

import static com.threerings.orth.Log.log;

/**
 * Manages {@link AetherClientObject#friends} and friend-related request for the local server.
 */
@Singleton
public class FriendManager implements Lifecycle.InitComponent, FriendProvider
{
    @Inject public FriendManager (Injector injector)
    {
        injector.getInstance(Lifecycle.class).addComponent(this);

        // register our bootstrap invocation service
        injector.getInstance(InvocationManager.class).registerProvider(
            this, FriendMarshaller.class, OrthCodes.AETHER_GROUP);
    }

    @Override
    public void init ()
    {
        _locator.addObserver(new AetherSessionLocator.Observer() {
            @Override public void playerLoggedIn (PresentsSession session, AetherClientObject plobj) {
                initFriends(plobj);
            }
            @Override public void playerWillLogout (PresentsSession session, AetherClientObject plobj) {
                shutdownFriends(plobj);
            }
        });
        _eyeballer.playerLoggedOn.connect(new Listener1<PeeredPlayerInfo>() {
            @Override public void apply (PeeredPlayerInfo info) {
                notifyFriends(info.authName.getId(), info);
            }
        });
        _eyeballer.playerLoggedOff.connect(new Listener1<AetherAuthName>() {
            @Override public void apply (AetherAuthName username) {
                notifyFriends(username.getId(), null);
            }
        });
        _eyeballer.playerInfoChanged.connect(new Listener1<PeeredPlayerInfo>() {
            @Override public void apply (PeeredPlayerInfo info) {
                notifyFriends(info.authName.getId(), info);
            }
        });
    }

    public void requestFriendship (final AetherClientObject caller, final int targetId,
        InvocationListener listener)
        throws InvocationException
    {
        AetherClientObject player = caller;
        final PlayerName playerName = player.playerName;

        // anti-spam logic
        final InviteThrottle throttle = player.getLocal(AetherLocal.class).getInviteThrottle();
        if (!throttle.allow(targetId)) {
            throw new InvocationException(AetherCodes.FRIEND_REQUEST_ALREADY_SENT);
        }

        // ok, notify the other player, wherever they are
        _peerMgr.invokeSingleNodeRequest(new AetherNodeRequest(targetId) {
            @Override protected void execute (AetherClientObject target, ResultListener listener) {
                FriendshipRequest req = new FriendshipRequest(playerName, target.playerName);
                CommSender.receiveComm(target, req);
                listener.requestProcessed(req);
            }
        }, new Resulting<FriendshipRequest>(listener) {
            @Override public void requestCompleted (FriendshipRequest result) {
                super.requestCompleted(result);
                CommSender.receiveComm(caller, result);
            }
            @Override public void requestFailed (Exception cause) {
                throttle.clear(targetId);
                super.requestFailed(cause);
            }
        });
    }

    public void endFriendship (final AetherClientObject caller, final int playerId,
        InvocationListener listener)
        throws InvocationException
    {
        FriendEntry entry = caller.friends.get(playerId);

        if (entry == null) {
            throw new InvocationException(AetherCodes.USER_IS_NOT_FRIEND);
        }

        if (!_friendRepo.removeFriendship(caller.getPlayerId(), playerId)) {
            // We crapped out removing the friendship from the db, so just say we had a problem
            // and leave it alone. They'll try again if they really hate this person, and hopefully
            // it'll stick
            throw new InvocationException(AetherCodes.E_INTERNAL_ERROR);
        }

        // I don't like you.
        caller.removeFromFriends(playerId);
        CommSender.receiveComm(caller, new FriendshipTermination(caller.playerName, entry.name));

        // You don't like me.
        _peerMgr.invokeNodeAction(new AetherNodeAction(playerId) {
            @Override
            protected void execute (AetherClientObject memobj) {
                memobj.removeFromFriends(caller.getPlayerId());
            }
        });
    }

    public void acceptFriendshipRequest (
        AetherClientObject caller, final int senderId, final InvocationListener listener)
        throws InvocationException
    {
        final AetherClientObject acceptingPlayer = caller;
        final PlayerName acceptingPlayerName = acceptingPlayer.playerName;

        // forward this acceptance to the server the other player is on
        _peerMgr.invokeNodeRequest(new AetherNodeRequest(senderId) {
            @Inject transient PeerEyeballer eyeballer;
            @Inject transient FriendManager friendmgr;
            @Override protected void execute (AetherClientObject sender, ResultListener listener) {
                AetherLocal local = sender.getLocal(AetherLocal.class);
                if (!local.getInviteThrottle().clear(acceptingPlayerName.getId())) {
                    log.warning("Uninvited friend acceptance!", "player", acceptingPlayerName,
                        "sender", _targetPlayer);
                    listener.requestFailed(AetherCodes.INTERNAL_ERROR);
                    return;
                }

                // add the friend!
                PeeredPlayerInfo other = eyeballer.getPlayerData(acceptingPlayerName.getId());
                if (other == null) {
                    log.warning("Edge case, accepting friend logged off before sender received " +
                        "notification of friendship", "sender", sender,
                        "accepting", acceptingPlayerName);
                } else {
                    friendmgr.addNewFriend(sender, other);
                    CommSender.receiveComm(sender,
                        new FriendshipAcceptance(sender.playerName, acceptingPlayerName));
                }


                // finished, go back to the original peer
                listener.requestProcessed(null);
            }
        }, new NodeRequestsListener<Void>() {
            @Override public void requestsProcessed (NodeRequestsResult<Void> result) {
                // all clear, add the friend!
                addNewFriend(acceptingPlayer, _eyeballer.getPlayerData(senderId));

                // persist: friends4evah
                _invoker.postRunnable(new Runnable() {
                    @Override public void run () {
                        _friendRepo.addFriendship(acceptingPlayer.getPlayerId(), senderId);
                    }
                    @Override public String toString () {
                       return "Add friends";
                    }
                });
            }
            @Override public void requestFailed (String cause) {
                listener.requestFailed(cause);
            }
        });
    }

    /**
     * Sets up the member's friends and adds to friend tracking.
     */
    protected void initFriends (final AetherClientObject player)
    {
        if (!player.friends.isEmpty()) {
            log.warning("Friends already? Something is very wrong.", "player", player.who());
            return;
        }

        final AetherLocal local = player.getLocal(AetherLocal.class);
        final List<FriendEntry> friends = Lists.newArrayListWithCapacity(
            local.unresolvedFriendIds.size());

        log.debug("Starting resolution of friends dset", "player", player.who(),
            "friends count", local.unresolvedFriendIds.size());
        Set<Integer> resolved = Sets.newHashSet();
        for (Integer friendId : local.unresolvedFriendIds) {
            PeeredPlayerInfo playerInfo = _eyeballer.getPlayerData(friendId);
            if (playerInfo != null) {
                friends.add(toFriendEntry(playerInfo));
                resolved.add(friendId);
            }
        }

        local.unresolvedFriendIds.removeAll(resolved);
        if (local.unresolvedFriendIds.isEmpty()) {
            updateFriends(player, friends);
            return;
        }

        // now we need to load the names for offline friends
        _invoker.postUnit(new Resulting<Map<Integer, String>>("Load offline friend names") {
            @Override public Map<Integer, String> invokePersist () throws Exception {
                // if this fails, we will be in a pretty bad state
                return _playerRepo.resolvePlayerNames(local.unresolvedFriendIds);
            }

            @Override public void requestCompleted (Map<Integer, String> result) {
                if (!player.isActive()) {
                    log.info("Player logged off prior to getting friends. Sad.",
                        "player", player.who());
                    return;
                }

                for (Map.Entry<Integer, String> pair : result.entrySet()) {
                    friends.add(offlineFriendEntry(pair.getKey(), pair.getValue()));
                }
                updateFriends(player, friends);
            }
        });
    }

    protected void updateFriends (AetherClientObject player, List<FriendEntry> friends)
    {
        // the player may have had some friends come online already while we were off in invoker
        // land. Replace the ones in the invoker list since the status should be more up to
        for (FriendEntry entry : player.friends) {
            friends.remove(entry.getKey()); // out with the resolved
            friends.add(entry); // in with the recently online
        }

        // set up the reverse listening map
        for (FriendEntry entry : friends) {
            _notifyMap.put(entry.name.getId(), player);
        }

        // set the friends
        player.setFriends(DSet.newDSet(friends));

        // clear out the holding buffer
        player.getLocal(AetherLocal.class).unresolvedFriendIds = null;

        log.debug("Finished resolution of friends dset", "player", player.who(),
            "friends count", player.friends.size());
    }

    protected void shutdownFriends (AetherClientObject player)
    {
        log.debug("Removing friend notifications", "player", player);

        for (FriendEntry entry : player.friends) {
            _notifyMap.remove(entry.name.getId(), player);
        }
    }

    protected void notifyFriends (int playerId, PeeredPlayerInfo info)
    {
        log.debug("Notifying friends", "playerId", playerId, "playerInfo", info);

        for (AetherClientObject friend : _notifyMap.get(playerId)) {
            FriendEntry entry = friend.friends.get(playerId);
            if (entry == null) {
                continue;
            }
            entry = entry.clone();
            populateEntry(entry, info);
            friend.updateFriends(entry);
        }
    }

    protected void populateEntry (FriendEntry entry, PeeredPlayerInfo info)
    {
        entry.whereabouts = (info != null) ? info.whereabouts : Whereabouts.OFFLINE;
    }

    protected void addNewFriend (AetherClientObject player, PeeredPlayerInfo other)
    {
        if (other == null) {
            return;
        }
        FriendEntry otherEntry = toFriendEntry(other);
        if (player.friends.contains(otherEntry)) {
            log.warning("Erk, player already contains friend", "player", player.who(),
                "other", other.visibleName, "isInNotifyMap",
                _notifyMap.containsKey(other.visibleName.getId()));
        } else {
            player.addToFriends(otherEntry);
        }
        _notifyMap.put(other.visibleName.getId(), player);
    }

    /**
     * Creates a new offline friend entry for the given player id and name. The status
     * message will be null.
     */
    protected FriendEntry offlineFriendEntry (int id, String name)
    {
        return new FriendEntry(new PlayerName(name, id), null, Whereabouts.OFFLINE);
    }

    /**
     * Creates a new friend entry, given a logged-on player's client info.
     */
    protected FriendEntry toFriendEntry (PeeredPlayerInfo info)
    {
        return new FriendEntry(info.visibleName, info.guildName, info.whereabouts);
    }

    /** Mapping of local and remote player ids to friend ids logged into this server. */
    protected SetMultimap<Integer, AetherClientObject> _notifyMap = HashMultimap.create();

    // dependencies
    @Inject protected AetherManager _aetherMgr;
    @Inject protected AetherSessionLocator _locator;
    @Inject protected OrthPeerManager _peerMgr;
    @Inject protected PeerEyeballer _eyeballer;
    @Inject protected PlayerRepository _playerRepo;
    @Inject protected RelationshipRepository _friendRepo;
    @Inject protected @MainInvoker Invoker _invoker;
}
