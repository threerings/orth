//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.client {
import flashx.funk.ioc.inject;

import com.threerings.util.Log;
import com.threerings.util.MessageManager;

import com.threerings.presents.client.Client;
import com.threerings.presents.dobj.DObjectManager;
import com.threerings.presents.util.PresentsContext;

import com.threerings.orth.aether.client.AetherClient;
import com.threerings.orth.aether.data.AetherClientObject;
import com.threerings.orth.data.PlayerName;
import com.threerings.orth.locus.client.AbstractLocusModule;
import com.threerings.orth.locus.client.LocusContext;
import com.threerings.orth.locus.client.LocusModule;

/**
 * This is the beating heart of an Orth-based client. It provides access to the Aether client
 * and its associated distributed object manager along with all the directors responsible for
 * the services that take place over the Aether link.
 *
 * <p>Whenever the player is in a locus location, this context additionally returns a non-null
 * reference to a <code>LocusContext</code>, which is the nexus of the entirely distinct other half
 * of the client's workings: a separate client connected to its own server and distributed object
 * system and, consequently, a different set of directors to take advantage of it all.</p>
 *
 * <p>Never confuse the two contexts. They represent different systems. This one is primary, in that
 * there is always an <code>OrthContext</code> and always an <code>AetherClient</code>, but only
 * some of the time is that true for <code>LocusContext</code> and <code>LocusClient</code>.</p>
 * @see LocusContext
 * @see LocusClient
 * @see AetherClient
 */
public class OrthContext
    implements PresentsContext
{
    public function OrthContext ()
    {
        // initialize our convenience holder
        Msgs.init(inject(MessageManager));
    }

    // called from OrthModule once this context and all its dependents are safely constructed
    public function didInit () :void
    {
    }

    public function get aetherClient () :AetherClient
    {
        return _client;
    }

    // from PresentsContext
    public function getClient () :Client
    {
        return _client;
    }

    // from PresentsContext
    public function getDObjectManager () :DObjectManager
    {
        return _client.getDObjectManager();
    }

    /**
     * Instantiate a new <code>AbstractLocusModule</code> and use it to fire up a
     * <code>LocusContext</code> of the correct concrete subtype, which in turn will instantiate
     * all the necessary infrastructure.
     * @see AbstractLocusModule
     */
    public function setupLocus (moduleClass :Class) :LocusContext
    {
        // instantiate the correct LocusModule subclass
        var wMod :AbstractLocusModule = new moduleClass();

        // and use it to bring the correct LocusContext subclass to life
        log.debug("Initializing new LocusContext", "module", moduleClass);
        return wMod.init(_module);
    }

    /**
     * Returns our connected <code>AetherClientObject</code>, or null if we are not logged on.
     * @see AetherClientObject
     */
    public function get aetherObject () :AetherClientObject
    {
        return (_client != null) ? _client.aetherObject : null;
    }

    /** For convenience, return our current display name. */
    public function get myName () :PlayerName
    {
        var player :AetherClientObject = aetherObject;
        return (player != null) ? player.playerName : null;
    }

    public function get myId () :int
    {
        var name :PlayerName = myName;
        return (name != null) ? name.id : 0;
    }

    protected const _client :AetherClient = inject(AetherClient);
    protected const _module :OrthModule = inject(OrthModule);

    protected static const log :Log = Log.getLog(OrthContext);
}
}
