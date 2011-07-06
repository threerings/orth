//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.guild.server;

import com.google.inject.Inject;
import com.google.inject.Injector;
import com.google.inject.Singleton;

import com.samskivert.util.Invoker;
import com.samskivert.util.ResultListener;

import com.threerings.presents.annotation.MainInvoker;
import com.threerings.presents.dobj.DObject;
import com.threerings.util.Resulting;

import com.threerings.orth.aether.data.AetherClientObject;
import com.threerings.orth.guild.data.GuildMarshaller;
import com.threerings.orth.guild.data.GuildNodelet;
import com.threerings.orth.guild.data.GuildObject;
import com.threerings.orth.guild.server.persist.GuildRecord;
import com.threerings.orth.guild.server.persist.GuildRepository;
import com.threerings.orth.nodelet.data.HostedNodelet;
import com.threerings.orth.nodelet.data.Nodelet;
import com.threerings.orth.nodelet.server.NodeletRegistry;
import com.threerings.orth.peer.data.OrthNodeObject;
import com.threerings.orth.server.OrthDeploymentConfig;

import static com.threerings.orth.Log.log;

/**
 * A nodelet registry configured for handling guild clients.
 */
@Singleton
public class GuildRegistry extends NodeletRegistry
{
    @Inject public GuildRegistry (Injector injector, OrthDeploymentConfig config)
    {
        super(GuildNodelet.class, config.getGuildHost(), config.getGuildPorts(), injector);
        setManagerClass(GuildManager.class, GuildObject.GUILD_SERVICE, GuildMarshaller.class);
        setPeeredHostingStrategy(OrthNodeObject.HOSTED_GUILDS, injector);
    }

    /**
     * Attempts to create a new guild and find a host for it. Upon success, the officer's
     * {@code guild} member will be updated to the new hosted location and the result listener
     * notified.
     */
    public void createAndHostGuild (final String name, final AetherClientObject officer,
            final ResultListener<HostedNodelet> rl)
    {
        _invoker.postUnit(new Resulting<GuildRecord>(
                "Creating guild", log, "officer", officer.who()) {
            @Override public GuildRecord invokePersist () throws Exception {
                return _guildRepo.createGuild(name, officer.getPlayerId());
            }

            @Override public void requestCompleted (GuildRecord result) {
                _hoster.resolveHosting(officer, new GuildNodelet(result.getGuildId()),
                        new Resulting<HostedNodelet>(rl) {
                    @Override public void requestCompleted (HostedNodelet result) {
                        officer.startTransaction();
                        try {
                            officer.setGuild(result); // Whoo, all done!
                            officer.setGuildId(((GuildNodelet)result.nodelet).guildId);
                        } finally {
                            officer.commitTransaction();
                        }
                        super.requestCompleted(result);
                    }
                });
            }

            @Override public void requestFailed (Exception cause) {
                rl.requestFailed(cause);
            }
        });
    }

    /**
     * Invoke the given guild request on the appropriate guild manager, wherever it may be in the
     * server cluster. Invokers failure on the listener if there the nodelet is not hosted or there
     * is an error invoking the request remotely.
     */
    public <T> void invokeRemoteRequest (int guildId, Request<T> request, ResultListener<T> lner)
    {
        super.invokeRemoteRequest(new GuildNodelet(guildId), request, lner);
    }

    @Override // from NodeletRegistry
    protected DObject createSharedObject (Nodelet nodelet)
    {
        return new GuildObject();
    }

    @Inject protected @MainInvoker Invoker _invoker;
    @Inject protected GuildRepository _guildRepo;
}
