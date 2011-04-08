package com.threerings.orth.guild.server;

import com.google.inject.Inject;
import com.google.inject.Injector;
import com.google.inject.Singleton;

import com.samskivert.util.Lifecycle;

import com.threerings.orth.guild.data.GuildObject;
import com.threerings.orth.nodelet.data.Nodelet;
import com.threerings.orth.nodelet.server.NodeletRegistry;
import com.threerings.orth.peer.data.OrthNodeObject;
import com.threerings.presents.dobj.DObject;

@Singleton
public class GuildRegistry extends NodeletRegistry
    implements Lifecycle.InitComponent
{
    @Inject public GuildRegistry (Injector injector)
    {
        super(OrthNodeObject.HOSTED_GUILDS, injector);
    }

    @Override
    public void init ()
    {
    }

    @Override
    protected DObject createSharedObject (Nodelet nodelet)
    {
        return new GuildObject();
    }
}
