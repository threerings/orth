//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.aether.server;

import com.google.common.base.Functions;
import com.google.inject.Inject;
import com.google.inject.Injector;
import com.google.inject.Singleton;

import com.samskivert.util.ResultListener;

import com.threerings.io.SimpleStreamableObject;
import com.threerings.util.Resulting;

import com.threerings.presents.annotation.EventThread;
import com.threerings.presents.client.InvocationService.ConfirmListener;
import com.threerings.presents.client.InvocationService.InvocationListener;
import com.threerings.presents.server.InvocationException;
import com.threerings.presents.server.InvocationManager;

import com.threerings.orth.aether.data.AetherClientObject;
import com.threerings.orth.aether.data.AetherCodes;
import com.threerings.orth.aether.data.AetherMarshaller;
import com.threerings.orth.data.OrthCodes;
import com.threerings.orth.guild.data.GuildCodes;
import com.threerings.orth.guild.server.GuildManager;
import com.threerings.orth.guild.server.GuildManager.HostingInfo;
import com.threerings.orth.guild.server.GuildRegistry;
import com.threerings.orth.nodelet.data.HostedNodelet;
import com.threerings.orth.nodelet.server.NodeletManager;
import com.threerings.orth.nodelet.server.NodeletRegistry;
import com.threerings.orth.peer.server.OrthPeerManager;

/**
 * Manage Orth Players.
 */
@Singleton @EventThread
public class AetherManager
    implements AetherProvider, AetherCodes
{
    @Inject public AetherManager (Injector injector)
    {
        // register our bootstrap invocation service
        injector.getInstance(InvocationManager.class).registerProvider(
            this, AetherMarshaller.class, OrthCodes.AETHER_GROUP);
    }

    @Override
    public void createGuild (AetherClientObject caller, String name, ConfirmListener lner)
        throws InvocationException
    {
        // TODO: permissions?
        AetherClientObject player = caller;
        if (player.guild != null) {
            throw new InvocationException(GuildCodes.E_PLAYER_ALREADY_IN_GUILD);
        }

        _guildReg.validateGuildName(name);
        _guildReg.createAndHostGuild(name, player, new Resulting<HostedNodelet>(lner));
    }

    @Override
    public void acceptGuildInvite (AetherClientObject caller, final int senderId, int guildId,
            InvocationListener lner)
        throws InvocationException
    {
        final AetherClientObject player = caller;
        final int playerId = player.getPlayerId();

        // they may have joined another guild since they got the invite
        if (player.guildName != null) {
            if (player.guildName.getGuildId() == guildId) {
                // in fact, they may have joined this precise one, in which case we're done
                return;
            }
            // otherwise scream and wail
            throw new InvocationException(GuildCodes.E_PLAYER_ALREADY_IN_GUILD);
        }

        // delegate to the possibly remote guild manager
        _guildReg.invokeRemoteRequest(guildId,
            new NodeletRegistry.Request<HostingInfo>() {
            @Override public void execute (NodeletManager mgr, ResultListener<HostingInfo> rl) {
                GuildManager gMgr = (GuildManager) mgr;
                gMgr.acceptInvite(senderId, playerId,
                    new Resulting<Void>(rl, Functions.constant(gMgr.getHostingInfo())));
            }

        }, new Resulting<HostingInfo>(lner) {
            @Override public void requestCompleted (HostingInfo result) {
                player.setGuildName(result.name);
                player.setGuild(result.nodelet);
            }
        });
    }

    protected static class AcceptGuildInviteResult extends SimpleStreamableObject
    {
        public String guildName;
        public HostedNodelet guildNodelet;
    }

    @Inject protected AetherSessionLocator _locator;
    @Inject protected OrthPeerManager _peermgr;
    @Inject protected FriendManager _friendMgr;
    @Inject protected GuildRegistry _guildReg;
}
