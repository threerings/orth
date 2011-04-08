package com.threerings.orth.guild.server;

import com.google.inject.Inject;
import com.google.inject.Injector;
import com.google.inject.Singleton;

import com.threerings.orth.guild.data.GuildObject;
import com.threerings.orth.nodelet.data.Nodelet;
import com.threerings.orth.nodelet.server.NodeletRegistry;
import com.threerings.orth.peer.data.OrthNodeObject;
import com.threerings.presents.dobj.DObject;

/**
 * A nodelet registry configured for handling guild clients.
 */
@Singleton
public class GuildRegistry extends NodeletRegistry
{
    @Inject public GuildRegistry (Injector injector)
    {
        super(OrthNodeObject.HOSTED_GUILDS, injector);
    }

    @Override // from NodeletRegistry
    protected DObject createSharedObject (Nodelet nodelet)
    {
        return new GuildObject();
    }
}
