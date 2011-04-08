package com.threerings.orth.guild.server;

import com.google.inject.Inject;
import com.google.inject.Injector;
import com.google.inject.Singleton;

import com.samskivert.util.Invoker;
import com.samskivert.util.ResultListener;

import com.threerings.orth.aether.data.PlayerObject;
import com.threerings.orth.data.AuthName;
import com.threerings.orth.guild.data.GuildNodelet;
import com.threerings.orth.guild.data.GuildObject;
import com.threerings.orth.guild.server.persist.GuildRecord;
import com.threerings.orth.guild.server.persist.GuildRepository;
import com.threerings.orth.nodelet.data.HostedNodelet;
import com.threerings.orth.nodelet.data.Nodelet;
import com.threerings.orth.nodelet.server.NodeletRegistry;
import com.threerings.orth.peer.data.OrthNodeObject;
import com.threerings.orth.server.OrthDeploymentConfig;
import com.threerings.presents.annotation.MainInvoker;
import com.threerings.presents.dobj.DObject;
import com.threerings.util.Resulting;

import static com.threerings.orth.Log.log;

/**
 * A nodelet registry configured for handling guild clients.
 */
@Singleton
public class GuildRegistry extends NodeletRegistry
{
    @Inject public GuildRegistry (Injector injector, OrthDeploymentConfig config)
    {
        super(OrthNodeObject.HOSTED_GUILDS, config.getGuildHost(), config.getGuildPorts(), injector);
    }

    /**
     * Attempts to create a new guild and find a host for it. Upon success, the officer's
     * {@code guild} member will be updated to the new hosted location and the result listener
     * notified.
     */
    public void createAndHostGuild (final String name, final PlayerObject officer,
            final ResultListener<HostedNodelet> rl)
    {
        _invoker.postUnit(new Resulting<GuildRecord>(
                "Creating guild", log, "officer", officer.who()) {
            @Override public GuildRecord invokePersist () throws Exception {
                return _guildRepo.createGuild(name, officer.getPlayerId());
            }

            @Override public void requestCompleted (GuildRecord result) {
                host((AuthName)officer.username, new GuildNodelet(result.getGuildId()),
                        new Resulting<HostedNodelet>(rl) {
                    @Override public void requestCompleted (HostedNodelet result) {
                        officer.setGuild(result); // Whoo, all done!
                        super.requestCompleted(result);
                    }
                });
            }

            @Override public void requestFailed (Exception cause) {
                rl.requestFailed(cause);
            }
        });
    }

    @Override // from NodeletRegistry
    protected DObject createSharedObject (Nodelet nodelet)
    {
        return new GuildObject();
    }

    @Inject protected @MainInvoker Invoker _invoker;
    @Inject protected GuildRepository _guildRepo;
}
