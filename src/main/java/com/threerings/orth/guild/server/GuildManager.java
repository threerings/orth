//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.guild.server;

import java.util.Map;

import com.google.common.base.Function;
import com.google.common.base.Predicate;
import com.google.common.collect.Iterables;
import com.google.common.collect.Maps;
import com.google.inject.Inject;

import com.samskivert.util.Invoker;
import com.samskivert.util.ResultListener;

import com.threerings.presents.annotation.MainInvoker;
import com.threerings.presents.client.InvocationService.InvocationListener;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.dobj.DSet;
import com.threerings.presents.server.InvocationException;
import com.threerings.util.Resulting;

import com.threerings.orth.aether.data.PlayerObject;
import com.threerings.orth.aether.data.VizPlayerName;
import com.threerings.orth.aether.server.PlayerNodeAction;
import com.threerings.orth.aether.server.PlayerNodeRequests;
import com.threerings.orth.data.AuthName;
import com.threerings.orth.guild.data.GuildCodes;
import com.threerings.orth.guild.data.GuildMemberEntry;
import com.threerings.orth.guild.data.GuildNodelet;
import com.threerings.orth.guild.data.GuildObject;
import com.threerings.orth.guild.data.GuildRank;
import com.threerings.orth.guild.server.persist.GuildMemberRecord;
import com.threerings.orth.guild.server.persist.GuildRecord;
import com.threerings.orth.guild.server.persist.GuildRepository;
import com.threerings.orth.nodelet.server.NodeletManager;
import com.threerings.orth.notify.data.GuildInviteNotification;
import com.threerings.orth.peer.data.OrthClientInfo;
import com.threerings.orth.peer.server.OrthPeerManager;
import com.threerings.orth.server.persist.OrthPlayerRepository;
import com.threerings.orth.server.util.InviteThrottle;

import static com.threerings.orth.Log.log;

/**
 * Manages a {@link GuildObject} on the server.
 */
public class GuildManager extends NodeletManager
    implements GuildProvider, GuildCodes
{
    @Override
    public boolean prepare (final ResultListener<Void> rl)
    {
        _invoker.postUnit(new Resulting<Iterable<GuildMemberEntry>>("Loading guild") {
            GuildRecord guild;
            @Override public Iterable<GuildMemberEntry> invokePersist () throws Exception {
                // get the data from the db
                guild = _guildRepo.getGuild(_guildId);
                Map<Integer, GuildMemberRecord> gmrecs = Maps.uniqueIndex(
                        _guildRepo.getGuildMembers(_guildId),
                        GuildMemberRecord.TO_PLAYER_ID);
                final Map<Integer, String> playerNames =
                        _playerRepo.resolvePlayerNames(gmrecs.keySet());

                // transform to entries
                return Iterables.transform(gmrecs.values(),
                        new Function<GuildMemberRecord, GuildMemberEntry>() {
                    public GuildMemberEntry apply (GuildMemberRecord gmrec) {
                        VizPlayerName vpn = new VizPlayerName(playerNames.get(gmrec.getPlayerId()),
                                gmrec.getPlayerId(), null);
                        return new GuildMemberEntry(vpn, gmrec.getRank());
                    }
                });
            }

            @Override public void requestCompleted (Iterable<GuildMemberEntry> result) {
                _guildObj.setName(guild.getName());
                _guildObj.setMembers(DSet.newDSet(result));
                rl.requestCompleted(null);
            }
        });
        return true;
    }

    @Override
    public void didInit ()
    {
        _guildObj = ((GuildObject)_sharedObject);
        _guildId = ((GuildNodelet)_nodelet.nodelet).guildId;
    }

    @Override
    public void sendInvite (ClientObject caller, int targetId, InvocationListener lner)
        throws InvocationException
    {
        GuildMemberEntry sender = requireMember(caller);
        if (sender.rank != GuildRank.OFFICER) {
            log.warning("Non officer attempting to send guild invite", "sender", sender,
                "targetId", targetId);
            throw new InvocationException(INTERNAL_ERROR);
        }
        if (_guildObj.members.containsKey(targetId)) {
            throw new InvocationException(E_PLAYER_ALREADY_IN_GUILD);
        }
        if (!getThrottle(sender).allow(targetId)) {
            throw new InvocationException(E_INVITE_ALREADY_SENT);
        }
        _requests.sendNotification(targetId, new GuildInviteNotification(sender.name.toPlayerName(),
            _guildObj.name, _guildId), new Resulting<Void>(lner));
    }

    @Override
    public void updateRank (ClientObject caller, int targetId, final GuildRank newRank,
            InvocationListener listener)
        throws InvocationException
    {
        GuildMemberEntry officer = requireMember(caller);
        if (officer.rank != GuildRank.OFFICER) {
            log.warning("Non officer attempting to update rank", "caller", officer,
                    "targetId", targetId);
            throw new InvocationException(E_INTERNAL_ERROR);
        }
        final GuildMemberEntry target = lookupMember(targetId);
        if (target == null) {
            throw new InvocationException(E_INTERNAL_ERROR);
        }
        if (target.rank == GuildRank.OFFICER) {
            log.warning("Illegal rank update", "caller", officer, "target", target);
            throw new InvocationException(E_INTERNAL_ERROR);
        }

        // all in order, ship off to invoker
        _invoker.postUnit(new Resulting<Void>("update guild member rank", listener) {
            @Override public Void invokePersist () throws Exception {
                _guildRepo.updateMember(_guildId, target.getPlayerId(), newRank);
                return null;
            }
            @Override public void requestCompleted (Void result) {
                GuildMemberEntry updated = target.clone();
                updated.rank = newRank;
                _guildObj.updateMembers(updated);
                super.requestCompleted(result);
            }
        });
    }

    @Override
    public void remove (ClientObject caller, int targetId, InvocationListener listener)
        throws InvocationException
    {
        GuildMemberEntry officer = requireMember(caller);
        if (officer.rank != GuildRank.OFFICER) {
            log.warning("Non officer attempting to remove member", "caller", officer,
                    "targetId", targetId);
            throw new InvocationException(E_INTERNAL_ERROR);
        }
        final GuildMemberEntry target = lookupMember(targetId);
        if (target == null) {
            throw new InvocationException(E_INTERNAL_ERROR);
        }
        if (target.rank == GuildRank.OFFICER) {
            log.warning("Illegal remove", "caller", officer, "target", target);
            throw new InvocationException(E_INTERNAL_ERROR);
        }

        // all in order, ship off to invoker
        _invoker.postUnit(new Resulting<Void>("remove guild member", listener) {
            @Override public Void invokePersist () throws Exception {
                _guildRepo.removeMember(_guildId, target.getPlayerId());
                return null;
            }
            @Override public void requestCompleted (Void result) {
                _guildObj.removeFromMembers(target.getPlayerId());
                clearPlayerObjectGuild(target.getPlayerId());
                super.requestCompleted(result);
            }
        });
    }

    @Override
    public void leave (ClientObject caller, InvocationListener listener)
        throws InvocationException
    {
        final GuildMemberEntry member = requireMember(caller);
        if (member.isOfficer()) {
            boolean hasOtherOfficer = false;
            for (GuildMemberEntry other : Iterables.filter(_guildObj.members, IS_OFFICER)) {
                if (!other.equals(member)) {
                    hasOtherOfficer = true;
                }
            }
            if (!hasOtherOfficer) {
                throw new InvocationException(E_INTERNAL_ERROR);
            }
        }

        _invoker.postUnit(new Resulting<Void>("remove guild member", listener) {
            @Override public Void invokePersist () throws Exception {
                _guildRepo.removeMember(_guildId, member.getPlayerId());
                return null;
            }
            @Override public void requestCompleted (Void result) {
                _guildObj.removeFromMembers(member.getKey());
                clearPlayerObjectGuild(member.getPlayerId());
                super.requestCompleted(result);
            }
        });
    }

    @Override
    public void disband (ClientObject caller, InvocationListener listener)
        throws InvocationException
    {
        final GuildMemberEntry member = requireMember(caller);
        if (_guildObj.members.size() > 1) {
            throw new InvocationException(E_GUILD_HAS_OTHER_MEMBERS);
        }
        _invoker.postUnit(new Resulting<Void>("disband guild", listener) {
            @Override public Void invokePersist () throws Exception {
                _guildRepo.removeMember(_guildId, member.getPlayerId());
                _guildRepo.removeEmptyGuild(_guildId);
                return null;
            }
            @Override public void requestCompleted (Void result) {
                _guildObj.removeFromMembers(member.getKey());
                clearPlayerObjectGuild(member.getPlayerId());
                super.requestCompleted(result);
                _registry.shutdownManager(GuildManager.this);
            }
        });
    }

    public void acceptInvite (int senderId, final int newMemberId, ResultListener<Void> rl)
    {
        GuildMemberEntry sender = lookupMember(senderId);
        if (sender == null) {
            log.warning("Invitation accepted from non-guild member", "senderId", senderId,
                "newMemberId", newMemberId);
            rl.requestFailed(null);
            return;
        }
        if (!getThrottle(sender).clear(newMemberId)) {
            log.warning("Unsent invitation accepted", "senderId", senderId,
                "newMemberId", newMemberId);
            rl.requestFailed(null);
            return;
        }
        OrthClientInfo clinfo = _peerMan.locatePlayer(newMemberId);
        if (clinfo == null) {
            // this could happen in theory if the player accepted the guild invite and logged off
            // immediately. Not worth handling
            rl.requestFailed(null);
            return;
        }
        final GuildMemberEntry newEntry = GuildMemberEntry.fromPlayerName(clinfo.playerName,
                GuildRank.MEMBER);
        // woo! add 'em to the guild
        _invoker.postUnit(new Resulting<Void>("add guild member", rl) {
            @Override public Void invokePersist () throws Exception {
                _guildRepo.addMember(_guildId, newMemberId, newEntry.rank);
                return null;
            }

            @Override public void requestCompleted (Void result) {
                _guildObj.addToMembers(newEntry);
                super.requestCompleted(result);
            }
        });
    }

    protected void clearPlayerObjectGuild (int playerId)
    {
        _peerMan.invokeNodeAction(new PlayerNodeAction(playerId) {
            @Override protected void execute (PlayerObject player) {
                player.startTransaction();
                try {
                    player.setGuildId(0);
                    player.setGuild(null);
                } finally {
                    player.commitTransaction();
                }
            }
        });
    }

    protected GuildMemberEntry requireMember (ClientObject caller)
        throws InvocationException
    {
        GuildMemberEntry entry = lookupMember(((AuthName)caller.username).getId());
        if (entry == null) {
            log.warning("Non guild member caller", "guild", _nodelet, "caller", caller.who());
            throw new InvocationException(E_INTERNAL_ERROR);
        }
        return entry;
    }

    protected GuildMemberEntry lookupMember (int playerId)
    {
        return _guildObj.members.get(playerId);
    }

    protected InviteThrottle getThrottle (GuildMemberEntry member)
    {
        return getThrottle(member.getPlayerId());
    }

    protected InviteThrottle getThrottle (int playerId)
    {
        if (_invitations == null) {
            _invitations = Maps.newHashMap();
        }
        InviteThrottle throttle = _invitations.get(playerId);
        if (throttle == null) {
            _invitations.put(playerId, throttle = new InviteThrottle());
        }
        return throttle;
    }

    protected GuildObject _guildObj;
    protected int _guildId;
    protected Map<Integer, InviteThrottle> _invitations;

    protected static final Predicate<GuildMemberEntry> IS_OFFICER =
            new Predicate<GuildMemberEntry> () {
        @Override public boolean apply (GuildMemberEntry entry) {
            return entry.isOfficer();
        }
    };

    // dependencies
    @Inject protected GuildRepository _guildRepo;
    @Inject protected OrthPlayerRepository _playerRepo;
    @Inject protected @MainInvoker Invoker _invoker;
    @Inject protected PlayerNodeRequests _requests;
    @Inject protected OrthPeerManager _peerMan;
}
