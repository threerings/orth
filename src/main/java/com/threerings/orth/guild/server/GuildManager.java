package com.threerings.orth.guild.server;

import java.util.Map;

import com.google.common.base.Function;
import com.google.common.collect.Iterables;
import com.google.common.collect.Maps;
import com.google.inject.Inject;

import com.samskivert.util.Invoker;
import com.samskivert.util.ResultListener;

import com.threerings.presents.annotation.MainInvoker;
import com.threerings.presents.client.InvocationService.InvocationListener;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.dobj.DObject;
import com.threerings.presents.dobj.DSet;
import com.threerings.presents.server.InvocationException;
import com.threerings.util.Resulting;

import com.threerings.orth.aether.data.VizPlayerName;
import com.threerings.orth.aether.server.PlayerNodeRequests;
import com.threerings.orth.data.AuthName;
import com.threerings.orth.guild.data.GuildCodes;
import com.threerings.orth.guild.data.GuildMemberEntry;
import com.threerings.orth.guild.data.GuildObject;
import com.threerings.orth.guild.data.GuildRank;
import com.threerings.orth.guild.server.persist.GuildMemberRecord;
import com.threerings.orth.guild.server.persist.GuildRecord;
import com.threerings.orth.guild.server.persist.GuildRepository;
import com.threerings.orth.nodelet.data.HostedNodelet;
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
                guild = _guildRepo.getGuild(_nodelet.getId());
                Map<Integer, GuildMemberRecord> gmrecs = Maps.uniqueIndex(
                        _guildRepo.getGuildMembers(_nodelet.getId()),
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

    public void init (HostedNodelet nodelet, DObject sharedObject)
    {
        super.init(nodelet, sharedObject);
        _guildObj = ((GuildObject)sharedObject);
    }

    @Override
    public void sendInvite (ClientObject caller, int targetId, InvocationListener lner)
        throws InvocationException
    {
        int senderId = ((AuthName)caller.username).getId();
        GuildMemberEntry entry = _guildObj.members.get(senderId);
        if (entry == null) {
            log.warning("Non guild member sending invite", "sender", caller.who(),
                    "senderId", senderId, "targetId", targetId);
            throw new InvocationException(E_INTERNAL_ERROR);
        }
        if (_guildObj.members.containsKey(targetId)) {
            throw new InvocationException(E_PLAYER_ALREADY_IN_GUILD);
        }
        // TODO: limit by rank
        if (!getThrottle(senderId).allow(targetId)) {
            throw new InvocationException(E_INVITE_ALREADY_SENT);
        }
        _requests.sendNotification(targetId, new GuildInviteNotification(entry.name.toPlayerName(),
            _guildObj.name, _nodelet.getId()), new Resulting<Void>(lner));
    }

    public void acceptInvite (int senderId, final int newMemberId, ResultListener<Void> rl)
    {
        GuildMemberEntry entry = _guildObj.members.get(senderId);
        if (entry == null) {
            log.warning("Invitation accepted from non-guild member", "senderId", senderId,
                "newMemberId", newMemberId);
            rl.requestFailed(null);
            return;
        }
        if (!getThrottle(senderId).clear(newMemberId)) {
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
                _guildRepo.addMember(_nodelet.getId(), newMemberId, newEntry.rank);
                return null;
            }

            @Override public void requestCompleted (Void result) {
                _guildObj.addToMembers(newEntry);
                super.requestCompleted(result);
            }
        });
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
    protected Map<Integer, InviteThrottle> _invitations;

    // dependencies
    @Inject protected GuildRepository _guildRepo;
    @Inject protected OrthPlayerRepository _playerRepo;
    @Inject protected @MainInvoker Invoker _invoker;
    @Inject protected PlayerNodeRequests _requests;
    @Inject protected OrthPeerManager _peerMan;
}
