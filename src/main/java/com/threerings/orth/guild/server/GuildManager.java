//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.guild.server;

import java.util.List;
import java.util.Map;

import com.google.common.base.Predicate;
import com.google.common.collect.Iterables;
import com.google.common.collect.Lists;
import com.google.common.collect.Maps;
import com.google.inject.Inject;

import com.samskivert.util.Invoker;
import com.samskivert.util.ResultListener;

import com.threerings.util.Resulting;

import com.threerings.presents.annotation.BlockingThread;
import com.threerings.presents.annotation.MainInvoker;
import com.threerings.presents.client.InvocationService.InvocationListener;
import com.threerings.presents.client.InvocationService;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.dobj.DSet;
import com.threerings.presents.server.InvocationException;
import com.threerings.presents.server.InvocationManager;

import com.threerings.orth.aether.data.AetherAuthName;
import com.threerings.orth.aether.data.AetherClientObject;
import com.threerings.orth.aether.data.PeeredPlayerInfo;
import com.threerings.orth.aether.server.AetherNodeAction;
import com.threerings.orth.aether.server.AetherNodeRequest;
import com.threerings.orth.aether.server.PeerEyeballer;
import com.threerings.orth.chat.data.OrthChatCodes;
import com.threerings.orth.chat.data.SpeakMarshaller;
import com.threerings.orth.chat.server.ChatManager;
import com.threerings.orth.chat.server.SpeakProvider;
import com.threerings.orth.comms.data.CommSender;
import com.threerings.orth.data.AuthName;
import com.threerings.orth.data.PlayerName;
import com.threerings.orth.data.where.Whereabouts;
import com.threerings.orth.guild.data.GuildCodes;
import com.threerings.orth.guild.data.GuildInviteNotification;
import com.threerings.orth.guild.data.GuildMemberEntry;
import com.threerings.orth.guild.data.GuildName;
import com.threerings.orth.guild.data.GuildNodelet;
import com.threerings.orth.guild.data.GuildObject;
import com.threerings.orth.guild.data.GuildRank;
import com.threerings.orth.guild.server.persist.GuildMemberRecord;
import com.threerings.orth.guild.server.persist.GuildRecord;
import com.threerings.orth.guild.server.persist.GuildRepository;
import com.threerings.orth.nodelet.server.NodeletManager;
import com.threerings.orth.peer.server.OrthPeerManager;
import com.threerings.orth.server.persist.PlayerRepository;
import com.threerings.orth.server.util.InviteThrottle;

import com.threerings.signals.Listener1;

import static com.threerings.orth.Log.log;

/**
 * Manages a {@link GuildObject} on the server.
 */
public class GuildManager extends NodeletManager
    implements GuildProvider, GuildCodes, SpeakProvider
{
    @Override
    public void didInit ()
    {
        _guildObj = ((GuildObject)_sharedObject);
        _guildId = ((GuildNodelet)_nodelet.nodelet).guildId;

        // add the Orth speak service for this guild
        _guildObj.guildChatService = _invmgr.registerProvider(this, SpeakMarshaller.class);

        _eyeballer.playerLoggedOn.connect(new Listener1<PeeredPlayerInfo>() {
            @Override public void apply (PeeredPlayerInfo info) {
                updateEntry(info.authName.getId(), info);
            }
        });
        _eyeballer.playerLoggedOff.connect(new Listener1<AetherAuthName>() {
            @Override public void apply (AetherAuthName username) {
                updateEntry(username.getId(), null);
            }
        });
        _eyeballer.playerInfoChanged.connect(new Listener1<PeeredPlayerInfo>() {
            @Override public void apply (PeeredPlayerInfo info) {
                updateEntry(info.authName.getId(), info);
            }
        });
    }

    @Override
    public boolean prepare (final ResultListener<Void> rl)
    {
        _invoker.postUnit(new Resulting<Void>("Loading guild") {
            protected GuildRecord _guild;
            protected Map<Integer, GuildMemberRecord> _members;
            protected Map<Integer, String> _names;
            @Override public Void invokePersist () throws Exception {
                // get the data from the db
                _guild = _guildRepo.getGuild(_guildId);
                _members = Maps.uniqueIndex(_guildRepo.getGuildMembers(_guildId),
                    GuildMemberRecord.TO_PLAYER_ID);
                _names = _playerRepo.resolvePlayerNames(_members.keySet());
                return null;
            }

            @Override public void requestCompleted (Void nothing) {
                List<GuildMemberEntry> entries = Lists.newArrayList();
                for (GuildMemberRecord gmrec : _members.values()) {
                    int playerId = gmrec.getPlayerId();
                    PeeredPlayerInfo info = _eyeballer.getPlayerData(playerId);
                    if (info != null) {
                        entries.add(toMemberEntry(info, gmrec.getRank()));
                        continue;
                    }
                    String nameStr = _names.get(playerId);
                    if (nameStr == null) {
                        log.warning("Huh? Nameless guild member?", "playerId", playerId);
                        continue;
                    }
                    PlayerName name = new PlayerName(_names.get(playerId), playerId);
                    entries.add(toMemberEntry(name, gmrec.getRank()));
                }

                _guildObj.setName(_guild.getName());
                _guildObj.setMembers(DSet.newDSet(entries));

                _guildName = new GuildName(_guild.getName(), _guild.getGuildId());

                rl.requestCompleted(null);
            }
        });
        return true;
    }

    public int getGuildId ()
    {
        return _guildId;
    }

    public GuildName getGuildName ()
    {
        return _guildName;
    }

    // from SpeakRouter
    @Override public void speak (ClientObject caller, String msg, InvocationListener listener)
        throws InvocationException
    {
        _chatMan.sendSpeak(_guildObj, requireMember(caller).name, msg,
            OrthChatCodes.GUILD_CHAT_TYPE, listener);
    }

    @Override
    public void sendInvite (ClientObject caller, int targetId, InvocationListener lner)
        throws InvocationException
    {
        final GuildMemberEntry sender = requireMember(caller);
        if (sender.rank != GuildRank.OFFICER) {
            log.warning("Non-officer attempting to send guild invite", "sender", sender,
                "targetId", targetId);
            throw new InvocationException(INTERNAL_ERROR);
        }
        if (_guildObj.members.containsKey(targetId)) {
            throw new InvocationException(E_PLAYER_ALREADY_IN_GUILD);
        }
        if (!getThrottle(sender).allow(targetId)) {
            throw new InvocationException(E_INVITE_ALREADY_SENT);
        }

        final String guildName = _guildObj.name;
        final int guildId = _guildId;
        _peerMan.invokeSingleNodeRequest(new AetherNodeRequest(targetId) {
            @Override protected void execute (AetherClientObject target,
                InvocationService.ResultListener listener) {
                // now that we're on their vault server, we can check if they're in a guild
                if (target.guild != null &&
                    ((GuildNodelet) target.guild.nodelet).guildId != _guildId) {
                    listener.requestFailed(GuildCodes.E_PLAYER_ALREADY_IN_GUILD);
                    return;
                }
                CommSender.receiveComm(target, new GuildInviteNotification(
                    sender.name, target.playerName, guildName, guildId));
                listener.requestProcessed(null);
            }
        }, new Resulting<Void>(lner));
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
            log.warning("Illegal rank update", "caller", officer.name, "target", target.name);
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
                didLeaveGuild(target.getPlayerId());
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
                didLeaveGuild(member.getPlayerId());
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
                didDisbandGuild(member.getPlayerId());
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

        final GuildMemberEntry newEntry = toMemberEntry(
            _eyeballer.getPlayerData(newMemberId), GuildRank.MEMBER);

        // woo! add 'em to the guild
        _invoker.postUnit(new Resulting<Void>("add guild member", rl) {
            @Override public Void invokePersist () throws Exception {
                _guildRepo.addMember(_guildId, newMemberId, newEntry.rank);
                didJoinGuild(newMemberId);
                return null;
            }

            @Override public void requestCompleted (Void result) {
                _guildObj.addToMembers(newEntry);
                super.requestCompleted(result);
            }
        });
    }

    @BlockingThread
    protected void didJoinGuild (int playerId)
    {
        // subclasses may react
    }

    @BlockingThread
    protected void didLeaveGuild (int playerId)
    {
        // subclasses may react
    }

    @BlockingThread
    protected void didDisbandGuild (int playerId)
    {
        // subclasses may react
    }

    protected void clearPlayerObjectGuild (int playerId)
    {
        _peerMan.invokeNodeAction(new AetherNodeAction(playerId) {
            @Override protected void execute (AetherClientObject player) {
                player.startTransaction();
                try {
                    player.setGuildName(null);
                    player.setGuild(null);
                } finally {
                    player.commitTransaction();
                }
            }
        });
    }

    protected void updateEntry (int playerId, PeeredPlayerInfo info)
    {
        GuildMemberEntry entry = _guildObj.members.get(playerId);
        if (entry == null) {
            // update on a player who's not in this guild, ignore
            return;
        }
        entry = entry.clone();
        populateEntry(entry, info);
        _guildObj.updateMembers(entry);
    }

    protected void populateEntry (GuildMemberEntry entry, PeeredPlayerInfo info)
    {
        entry.whereabouts = (info != null) ? info.whereabouts : Whereabouts.OFFLINE;
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

    /**
     * Creates a new guild member entry when we only know the name and rank.
     */
    protected GuildMemberEntry toMemberEntry (PlayerName name, GuildRank rank)
    {
        return new GuildMemberEntry(name, _guildName, rank, Whereabouts.OFFLINE);
    }

    /**
     * Creates a new guild member entry for an online player.
     */
    protected GuildMemberEntry toMemberEntry (PeeredPlayerInfo info, GuildRank rank)
    {
        return new GuildMemberEntry(info.visibleName, _guildName, rank, info.whereabouts);
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

    protected int _guildId;
    protected GuildObject _guildObj;
    protected GuildName _guildName;
    protected Map<Integer, InviteThrottle> _invitations;

    protected static final Predicate<GuildMemberEntry> IS_OFFICER =
        new Predicate<GuildMemberEntry> () {
        @Override public boolean apply (GuildMemberEntry entry) {
            return entry.isOfficer();
        }
    };

    // dependencies
    @Inject protected GuildRepository _guildRepo;
    @Inject protected InvocationManager _invmgr;
    @Inject protected @MainInvoker Invoker _invoker;
    @Inject protected ChatManager _chatMan;
    @Inject protected OrthPeerManager _peerMan;
    @Inject protected PeerEyeballer _eyeballer;
    @Inject protected PlayerRepository _playerRepo;
}
