//
// $Id$

package com.threerings.orth.client {

import mx.core.Application;

import flash.display.Stage;

import org.swiftsuspenders.Injector;

import com.threerings.util.Log;
import com.threerings.util.MessageManager;
import com.threerings.util.Name;

import com.threerings.presents.client.Client;
import com.threerings.presents.dobj.DObjectManager;
import com.threerings.presents.util.PresentsContext;

import com.threerings.orth.aether.client.AetherClient;
import com.threerings.orth.aether.data.AetherCredentials;

import com.threerings.orth.world.client.WorldContext;

/**
 * This is the beating heart of an Orth-based client. It provides access to the Aether client
 * and its associated distributed object manager along with all the directors responsible for
 * the services that take place over the Aether link.
 *
 * Whenever the player is in a world location, this context additionally returns a non-null
 * reference to a {@link WorldContext}, which is the nexus of the entirely distinct other half
 * of the client's workings: a separate client connected to its own server and distributed object
 * system and, consequently, a different set of directors to take advantage of it all.
 *
 * Never confuse the two contexts. They represent different systems. This one is primary, in that
 * there is always an {@link OrthContext} and always an {@link AetherClient}, but only some of
 * the time is that true for {@link WorldContext} and {@link WorldClient}.
 */
public class OrthContext
    implements PresentsContext
{
    public static function run (app :Application) :OrthContext
    {
        return runClient(app, OrthContext, new OrthModule());
    }

    public static function runClient (
        app :Application, ctxClass :Class, module :OrthModule) :OrthContext
    {
        // create our injector
        var injector :Injector = new Injector();

        // then set up orth bindings
        module.configure(app, injector);

        var ctx :OrthContext = new ctxClass();

        // first hard-code the un-injected contexrt
        injector.mapValue(OrthContext, ctx);

        injector.injectInto(ctx);

        return ctx;
    }

    [Inject(name="policyPort")]
    public function initPolicyLoader (policyPort :int) :void
    {
        // initialize the policy loader
        PolicyLoader.init(policyPort);
    }

    [PostConstruct]
    public function initialize () :void
    {
        // initialize our convenience holder
        Msgs.init(_msgMgr);

        // more startup bits will be added here in time...
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
     * To be explicitly called when we've created a {@link WorldContext} with a {@link WorldClient}
     * and are about to log into the corresponding world server.
     */
    public function enterWorld (ctxClass :Class, hostname :String, ports :Array) :void
    {
        if (_wctx != null) {
            log.error("Aii! Being given a new world context with an old one in place!");
            // but let it happen
        }

        // for now, fish our username out of our aether creds. should always be correct,
        // but possibly not the most elegant

        var username :Name = AetherCredentials(_client.getCredentials()).getUsername();

        // create (but do not inject) the concrete WorldContext subclass we were given
        _wctx = new ctxClass();

        // configure the host/ports to connect to
        _injector.mapValue(String, hostname, "worldHostname");
        _injector.mapValue(Array, ports, "worldPorts");

        // map WorldClass to our instance for the duration of this world session
        _injector.mapValue(WorldContext, _wctx);

        // and perform injection, bootstrapping the world logon proceure
        _wctx = _injector.getInstance(ctxClass);
    }

    /**
     * To be explicitly called when we've finished leaving a world location.
     */
    public function leftWorld () :void
    {
        if (_wctx == null) {
            log.error("Aii Leaving the world with no configured world context.");
            // but let it happen
        }
        _wctx == null;
    }

    [Inject] public var _injector :Injector;
    [Inject] public var _client :AetherClient;
    [Inject] public var _msgMgr :MessageManager;

    protected var _wctx :WorldContext;

    protected static const log :Log = Log.getLog(OrthContext);
}
}
