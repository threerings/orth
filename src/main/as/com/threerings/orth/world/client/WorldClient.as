//
// $Id: WorldClient.as 19262 2010-07-13 22:28:11Z zell $

package com.threerings.orth.world.client {
import com.threerings.crowd.client.CrowdClient;
import com.threerings.orth.client.ContextMenuProvider;
import com.threerings.orth.data.OrthName;
import com.threerings.orth.world.client.WorldContext;
import com.threerings.orth.client.PlaceBox;
import com.threerings.orth.client.Prefs;
import com.threerings.orth.room.client.RoomObjectView;

import flash.display.DisplayObject;
import flash.display.Stage;
import flash.display.StageQuality;
import flash.events.Event;
import flash.events.IEventDispatcher;
import flash.geom.Point;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLVariables;

import flash.utils.Dictionary;

import com.adobe.crypto.MD5;

import com.threerings.util.Log;
import com.threerings.util.Name;

import com.threerings.presents.client.ClientAdapter;
import com.threerings.presents.client.ClientEvent;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.dobj.DObjectManager;
import com.threerings.presents.net.BootstrapData;
import com.threerings.presents.net.Credentials;

import com.threerings.whirled.data.Scene;

import mx.core.Application;


/**
 * Handles the main services for the world and game clients.
 */
public class WorldClient extends CrowdClient
{
    WorldMarshaller; // static reference for deserialization

    public function WorldClient (app :Application, version :String, host :String,
        ports :Array, socketPolicyPort :int)
    {
        super(null);

        _app = app;
        _socketPolicyPort = socketPolicyPort;

        setVersion(DeploymentConfig.version);

        LoggingTargets.configureLogging(_wctx);
        log.info("Starting up", "capabilities", Capabilities.serverString);

        // now create our credentials and context
        setCredentials(createStartupCreds(null));
        _wctx = createContext();

        // prior to logging on to a server, set up our security policy for that server
        addClientObserver(new ClientAdapter(clientWillLogon));

        // configure our server and port info
        setServer(host, ports);

        // set up a context menu that blocks funnybiz on the stage
        var menu :ContextMenu = new ContextMenu();
        menu.hideBuiltInItems();
        app.contextMenu = menu;
        menu.addEventListener(ContextMenuEvent.MENU_SELECT, contextMenuWillPopUp);

        logon();
    }

    /**
     * Return the Application.
     */
    public function getApplication () :Application
    {
        return _app;
    }

    /**
     * Return the Stage.
     */
    public function getStage () :Stage
    {
        return _app.stage;
    }

    /**
     * Called just before we logon to a server.
     *
     * Any time we're about to connect to a server, this method must be called. It loads the
     * appropriate security policy file for the host in question and ensures that we don't do it
     * more than once per host (which sometimes causes weirdness).
     */
    protected function clientWillLogon (event :ClientEvent) :void
    {
        var hostName :String = getHostName();

        if (!_loadedPolicies[hostName]) {
            var url :String = "xmlsocket://" + hostName + ":" + _socketPolicyPort;
            log.info("Loading security policy", "url", url);
            Security.loadPolicyFile(url);
            _loadedPolicies[hostName] = true;
        }
    }

    // from Client
    override public function gotBootstrap (data :BootstrapData, omgr :DObjectManager) :void
    {
        super.gotBootstrap(data, omgr);

        // save any machineIdent or sessionToken from the server.
        var rdata :MsoyAuthResponseData = (getAuthResponseData() as MsoyAuthResponseData);
        if (rdata.ident != null) {
            Prefs.setMachineIdent(rdata.ident);
        }

        // store the session token
        _ctx.saveSessionToken(getAuthResponseData());

        log.info("Client logged on",
            "build", DeploymentConfig.buildTime, "mediaURL", DeploymentConfig.mediaURL,
            "staticMediaURL", DeploymentConfig.staticMediaURL);
    }
    /**
     * Creates the context we'll use with this client.
     */
    protected function createContext () :WorldContext
    {
        return new WorldContext(this);
    }

    protected function populateContextMenu (custom :Array) :void
    {
        try {
            var allObjects :Array = _stage.getObjectsUnderPoint(
                new Point(_stage.mouseX, _stage.mouseY));
            var seen :Dictionary = new Dictionary();
            for each (var disp :DisplayObject in allObjects) {
                try {
                    while (disp != null && !(disp in seen)) {
                        seen[disp] = true;
                        if (disp is ContextMenuProvider) {
                            (disp as ContextMenuProvider).populateContextMenu(_wctx, custom);
                        }
                        disp = disp.parent;
                    }
                } catch (serr :SecurityError) {
                    // that's ok, let's move on
                }
            }
        } catch (e :Error) {
            log.warning("Error populating context menu", e);
        }
    }

    protected function createStartupCreds (token :String) :Credentials
    {
        var params :Object = MsoyParameters.get();
        var creds :WorldCredentials;
        var anonymous :Boolean;

        if ((params["pass"] != null) && (params["user"] != null)) {
            creds = new WorldCredentials(
                new Name(String(params["user"])), MD5.hash(String(params["pass"])));
            anonymous = false;

        } else {
            creds = new WorldCredentials(null, null);
            anonymous = true;
        }

        creds.sessionToken = (token == null) ? params["token"] : token;
        creds.ident = Prefs.getMachineIdent();
        creds.vector = getEntryVector();

        return creds;
    }

    protected _app :Application;

    protected var _wctx :WorldContext;

    protected var _socketPolicyPort :int;

    protected var _loadedPolicies :Object = new Object();

    private static const log :Log = Log.getLog(WorldClient);
}
}
