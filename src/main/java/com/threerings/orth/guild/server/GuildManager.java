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
import com.threerings.orth.guild.data.GuildMemberEntry;
import com.threerings.orth.guild.data.GuildObject;
import com.threerings.orth.guild.server.persist.GuildMemberRecord;
import com.threerings.orth.guild.server.persist.GuildRecord;
import com.threerings.orth.guild.server.persist.GuildRepository;
import com.threerings.orth.nodelet.data.HostedNodelet;
import com.threerings.orth.nodelet.server.NodeletManager;
import com.threerings.orth.server.persist.OrthPlayerRepository;

/**
 * Manages a {@link GuildObject} on the server.
 */
public class GuildManager extends NodeletManager
    implements GuildProvider
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
    public void sendInvite (ClientObject caller, int arg1, InvocationListener arg2)
        throws InvocationException
    {
        // TODO
    }

    public void acceptInvite (int senderId, int newMemberId, ResultListener<Void> rl)
    {
        // TODO
        rl.requestCompleted(null);
    }

    protected GuildObject _guildObj;

    @Inject protected GuildRepository _guildRepo;
    @Inject protected OrthPlayerRepository _playerRepo;
    @Inject protected @MainInvoker Invoker _invoker;
}