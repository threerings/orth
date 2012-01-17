//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.aether.server;

import com.google.common.base.Functions;
import com.google.inject.Inject;
import com.google.inject.Injector;
import com.google.inject.Singleton;

import com.samskivert.util.ResultListener;

import com.threerings.util.Resulting;

import com.threerings.presents.annotation.EventThread;
import com.threerings.presents.client.InvocationService.InvocationListener;
import com.threerings.presents.server.InvocationException;
import com.threerings.presents.server.InvocationManager;

import com.threerings.orth.aether.data.AetherClientObject;
import com.threerings.orth.aether.data.AetherCodes;
import com.threerings.orth.aether.data.AetherMarshaller;
import com.threerings.orth.data.OrthCodes;
import com.threerings.orth.guild.data.GuildCodes;
import com.threerings.orth.guild.data.GuildNodelet;
import com.threerings.orth.guild.server.GuildManager;
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
    public void createGuild (AetherClientObject caller, String name, InvocationListener lner)
        throws InvocationException
    {
        // TODO: permissions and money
        AetherClientObject player = caller;
        if (player.guild != null) {
            throw new InvocationException(GuildCodes.E_PLAYER_ALREADY_IN_GUILD);
        }
        if (name.length() == 0) {
            throw new InvocationException(E_INTERNAL_ERROR);
        }

        _guildReg.createAndHostGuild(name, player, new Resulting<HostedNodelet>(lner));
    }

    @Override
    public void acceptGuildInvite (AetherClientObject caller, final int senderId, int guildId,
            InvocationListener lner)
        throws InvocationException
    {
        final AetherClientObject player = caller;
        final int playerId = player.getPlayerId();

        // delegate to the possibly remote guild manager
        _guildReg.invokeRemoteRequest(guildId, new NodeletRegistry.Request<HostedNodelet>() {
            @Override public void execute (NodeletManager manager,
                    ResultListener<HostedNodelet> rl) {
                ((GuildManager)manager).acceptInvite(senderId, playerId,
                        new Resulting<Void>(rl, Functions.constant(manager.getNodelet())));
            }

        }, new Resulting<HostedNodelet>(lner) {
            @Override public void requestCompleted (HostedNodelet result) {
                player.setGuildId(((GuildNodelet)result.nodelet).guildId);
                player.setGuild(result);
            }
        });
    }

    @Inject protected AetherSessionLocator _locator;
    @Inject protected OrthPeerManager _peermgr;
    @Inject protected FriendManager _friendMgr;
    @Inject protected GuildRegistry _guildReg;
}
