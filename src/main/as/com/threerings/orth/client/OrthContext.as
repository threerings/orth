//
// $Id$

package com.threerings.orth.client {
import com.threerings.orth.aether.data.AetherCredentials;
import com.threerings.util.Log;
import com.threerings.util.MessageManager;
import com.threerings.util.Name;

import mx.core.Application;

import flash.display.Stage;

import com.threerings.presents.client.Client;
import com.threerings.presents.dobj.DObjectManager;
import com.threerings.presents.util.PresentsContext;

import com.threerings.orth.aether.client.AetherClient;

import com.threerings.orth.world.client.WorldContext;

/**
 * This is the beating heart of an Orth-based client. It provides access to the Aether client
 * and its associated distributed object manager along with all the directors responsible for
 * the services that take place over the Aether link.
 *
 * Whenever the player is in a world location, this context additionally returns a non-null
 * reference to a {@link com.threerings.orth.world.client.WorldContext}, which is the nexus of the entirely distinct other half
 * of the client's workings: a separate client connected to its own server and distributed object
 * system and, consequently, a different set of directors to take advantage of it all.
 *
 * Never confuse the two contexts. They represent different systems. This one is primary, in that
 * there is always an {@link OrthContext} and always an {@link AetherClient}, but only some of
 * the time is that true for {@link com.threerings.orth.world.client.WorldContext} and {@link WorldClient}.
 */
public class OrthContext
    implements PresentsContext
{
    public function OrthContext (app :Application, hostname :String, ports :Array, policyPort :int)
    {
        _app = app;

        // initialize the policy loader
        PolicyLoader.init(policyPort);

        // initialize the message manager
        _msgMgr = new MessageManager();
        // and our convenience holder
        Msgs.init(_msgMgr);

        // the top panel's constructor will add it to the app's UI hierarchy
        _topPanel = new TopPanel(this);

        // create our ur-client
        _client = new AetherClient(this, hostname, ports);

        _controller = new OrthController(this, _topPanel);
    }

    /**
     * Return a reference to our {@link AetherClient}.
     */
    public function get client () :AetherClient
    {
        return _client;
    }

    /**
     * Return a reference to the top-level Application.
     */
    public function get app () :Application
    {
        return _app;
    }

    /**
     * Return a reference to our {@link com.threerings.orth.client.TopPanel}, the single child of our {@link Application}.
     */
    public function get topPanel () :TopPanel
    {
        return _topPanel;
    }

    /**
     * Get the width of the client.
     *
     * By default this is just the stage width, but subclasses may override this method.
     */
    public function getWidth () :Number
    {
        return _app.stage.stageWidth;
    }

    /**
     * Get the width of the client.
     *
     * By default this is just the stage height, but subclasses may override this method.
     */
    public function getHeight () :Number
    {
        return _app.stage.stageHeight;
    }

    /**
     * Return a reference to our Stage.
     */
    public function get stage () :Stage
    {
        return _app.stage;
    }

    /**
     * Return a reference to the {@link com.threerings.orth.client.OrthController}.
     */
    public function get controller () :OrthController
    {
        return _controller;
    }

    /**
     * Returns a reference to our Message Manager. This is as global singleton.
     */
    public function getMessageManager () :MessageManager
    {
        return _msgMgr;
    }


    /**
     * Returns our current deployment configuration. These are constant that vary from build to
     * build but are not fetched over the wire. They are typically compiled into the client.
     *
     * The Orth layer uses a nonsensical development configuration. This method should be
     * overridden in any real application.
     */
    public function get deployment () :DeploymentConfig
    {
        return _config;
    }

    /**
     * Returns a reference to the current {@link com.threerings.orth.world.client.WorldContext}, if there is one, or null if we
     * are not currently in a location.
     */
    public function get wctx () :WorldContext
    {
        return _wctx;
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

    public function saveSessionToken (sessionToken :String):void
    {
        _sessionToken = sessionToken;
    }

    /**
     * To be explicitly called when we've created a {@link com.threerings.orth.world.client.WorldContext} with a {@link WorldClient}
     * and are about to log into the corresponding world server.
     */
    public function enterWorld (hostname :String, ports :Array) :void
    {
        if (_wctx != null) {
            log.error("Aii! Being given a new world context with an old one in place!");
            // but let it happen
        }

        // for now, fish our username out of our aether creds. should always be correct,
        // but possibly not the most elegant

        var username :Name = AetherCredentials(_client.getCredentials()).getUsername();

        // creating the new context will create the client and trigger the login
        _wctx = new WorldContext(this, hostname, ports, username, _sessionToken);
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

    protected var _app :Application;
    protected var _client :AetherClient;
    protected var _topPanel :TopPanel;
    protected var _controller :OrthController;
    protected var _config :DeploymentConfig = new OrthDeploymentConfig();

    protected var _wctx :WorldContext;

    protected var _msgMgr :MessageManager;

    protected var _sessionToken :String;

    private static var log :Log = Log.getLog(OrthContext);

}
}

import com.threerings.orth.client.DeploymentConfig;

class OrthDeploymentConfig implements DeploymentConfig
{
    public function getVersion () :String
    {
        return "DEV";
    }

    public function isDevelopment () :Boolean
    {
        return true;
    }
}
