//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.guild.server;

import com.google.inject.Inject;
import com.google.inject.Injector;
import com.google.inject.Singleton;

import com.samskivert.util.Invoker;
import com.samskivert.util.ResultListener;

import com.threerings.util.Resulting;

import com.threerings.presents.annotation.BlockingThread;
import com.threerings.presents.annotation.MainInvoker;
import com.threerings.presents.data.InvocationCodes;
import com.threerings.presents.dobj.DObject;
import com.threerings.presents.server.InvocationException;

import com.threerings.orth.aether.data.AetherClientObject;
import com.threerings.orth.guild.data.GuildCodes;
import com.threerings.orth.guild.data.GuildMarshaller;
import com.threerings.orth.guild.data.GuildName;
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
        setManagerClass(getGuildManagerClass(), GuildObject.GUILD_SERVICE, GuildMarshaller.class);
        setPeeredHostingStrategy(OrthNodeObject.HOSTED_GUILDS, injector);
    }

    /**
     * Checks the proposed name against whatever rules are appropriate, throwing an
     * InvocationException describing why we don't like it if we don't.
     */
    public void validateGuildName (String name)
        throws InvocationException
    {
        if (name == null || name.length() == 0) {
            throw new InvocationException(InvocationCodes.E_INTERNAL_ERROR);
        }
    }

    /**
     * Attempts to create a new guild and find a host for it. Upon success, the officer's
     * {@code guild} member will be updated to the new hosted location and the result listener
     * notified.
     */
    public void createAndHostGuild (final String name, final AetherClientObject officer,
            final ResultListener<HostedNodelet> rl)
    {
        // note that this Resulting() is not passed the incoming listener
        _invoker.postUnit(new Resulting<GuildRecord>("Creating guild") {
            @Override public GuildRecord invokePersist () throws Exception {
                if (_guildRepo.getGuild(name) != null) {
                    log.warning("Tried to create duplicate guild",
                        "name", name, "officer", officer);
                    throw new InvocationException(GuildCodes.E_GUILD_ALREADY_EXISTS);
                }
                GuildRecord rec = _guildRepo.createGuild(name, officer.getPlayerId());
                didCreateGuild(officer.getPlayerId(), rec.getGuildId());
                return rec;
            }
            @Override public void requestCompleted (GuildRecord result) {
                hostGuild(result, officer, rl);
            }
            @Override public void requestFailed (Exception cause) {
                rl.requestFailed(cause);
            }
        });
    }

    @BlockingThread
    protected void didCreateGuild (int playerId, int guildId)
    {
        // subclasses may react
    }

    /**
     * Attempts to host a guild that has already been created in the repository. Upon success, the
     * officer's {@code guild} member will be updated to the new hosted location and the result
     * listener notified.
     */
    public void hostGuild (GuildRecord gRec, final AetherClientObject officer,
        ResultListener<HostedNodelet> rl)
    {
        final GuildName gName = new GuildName(gRec.getName(), gRec.getGuildId());
        _hoster.resolveHosting(officer, new GuildNodelet(gName.getGuildId()),
            new Resulting<HostedNodelet>(rl) {
                @Override public void requestCompleted (HostedNodelet result) {
                    officer.startTransaction();
                    try {
                        officer.setGuild(result); // Whoo, all done!
                        officer.setGuildName(gName);
                    } finally {
                        officer.commitTransaction();
                    }
                    super.requestCompleted(result);
                }
            });
    }

    /**
     * Invoke the given guild request on the appropriate guild manager, wherever it may be in the
     * server cluster. Invoker failure on the listener if the nodelet is not hosted or there
     * is an error invoking the request remotely.
     */
    public <T> void invokeRemoteRequest (int guildId, Request<T> request, ResultListener<T> lner)
    {
        super.invokeRemoteRequest(new GuildNodelet(guildId), request, lner);
    }

    @Override // from NodeletRegistry
    public DObject createSharedObject (Nodelet nodelet)
    {
        return new GuildObject();
    }

    /**
     * The {@link GuildManager} subclass to instantiate. Meant for subclassing.
     */
    protected Class<? extends GuildManager> getGuildManagerClass ()
    {
        return GuildManager.class;
    }

    @Inject protected @MainInvoker Invoker _invoker;
    @Inject protected GuildRepository _guildRepo;
}
