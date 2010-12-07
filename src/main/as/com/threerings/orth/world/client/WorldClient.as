//
// $Id: WorldClient.as 19262 2010-07-13 22:28:11Z zell $

package com.threerings.orth.world.client {

import com.threerings.crowd.client.CrowdClient;
import com.threerings.orth.client.Msgs;
import com.threerings.orth.client.OrthContext;
import com.threerings.ui.MenuUtil;

import flash.display.DisplayObject;
import flash.display.Stage;
import flash.events.ContextMenuEvent;
import flash.geom.Point;
import flash.system.Capabilities;
import flash.system.Security;
import flash.ui.ContextMenu;
import flash.utils.Dictionary;

import mx.core.Application;

import com.threerings.util.Log;

import com.threerings.presents.client.ClientAdapter;
import com.threerings.presents.client.ClientEvent;
import com.threerings.presents.dobj.DObjectManager;
import com.threerings.presents.net.BootstrapData;

import com.threerings.orth.client.ContextMenuProvider;
import com.threerings.orth.client.Prefs;
import com.threerings.orth.world.data.WorldMarshaller;

import com.threerings.orth.data.OrthAuthResponseData;
import com.threerings.orth.world.data.WorldCredentials;

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

        // configure our version
        setVersion(version);

        // configure our server and port info
        setServer(host, ports);

        log.info("Starting up", "capabilities", Capabilities.serverString);

        // now create our credentials
        var creds :WorldCredentials = createStartupCreds();
        creds.ident = Prefs.getMachineIdent();
        setCredentials(creds);

        //  and context
        _wctx = WorldContext(createContext());

        // prior to logging on to a server, set up our security policy for that server
        addClientObserver(new ClientAdapter(clientWillLogon));

        // set up a context menu that blocks funnybiz on the stage
        var menu :ContextMenu = new ContextMenu();
        menu.hideBuiltInItems();
        app.contextMenu = menu;
        menu.addEventListener(ContextMenuEvent.MENU_SELECT, contextMenuWillPopUp);

        // finally logon
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
        var hostName :String = getHostname();

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
        var rdata :OrthAuthResponseData = (getAuthResponseData() as OrthAuthResponseData);
        if (rdata.ident != null) {
            Prefs.setMachineIdent(rdata.ident);
        }

        // store the session token
        _wctx.saveSessionToken(getAuthResponseData());
    }

    /**
     * Creates the context we'll use with this client.
     */
    protected function createContext () :OrthContext
    {
        return new WorldContext(this);
    }


    protected function createStartupCreds () :WorldCredentials
    {
        throw new Error("abstract");
    }

    /**
     * Called to process ContextMenuEvent.MENU_SELECT.
     */
    protected function contextMenuWillPopUp (event :ContextMenuEvent) :void
    {
        var menu :ContextMenu = (event.target as ContextMenu);
        var custom :Array = menu.customItems;
        custom.length = 0;

        populateContextMenu(custom);

        // HACK: putting the separator in the menu causes the item to not
        // work in linux, so we don't do it in linux.
        var useSep :Boolean = (-1 == Capabilities.os.indexOf("Linux"));

        // add the About menu item
        custom.push(MenuUtil.createCommandContextMenuItem(
            Msgs.GENERAL.get("b.about"), WorldController.ABOUT, null, useSep));

        // then, the menu will pop up
    }

    protected function populateContextMenu (custom :Array) :void
    {
        var stage :Stage = _wctx.getStage();
        try {
            var allObjs :Array = stage.getObjectsUnderPoint(new Point(stage.mouseX, stage.mouseY));
            var seen :Dictionary = new Dictionary();
            for each (var disp :DisplayObject in allObjs) {
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

    protected var _app :Application;

    protected var _wctx :WorldContext;

    protected var _socketPolicyPort :int;

    protected var _loadedPolicies :Object = new Object();

    private static const log :Log = Log.getLog(WorldClient);
}
}
