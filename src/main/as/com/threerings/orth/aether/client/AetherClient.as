//
// $Id$

package com.threerings.orth.aether.client {

import com.threerings.orth.aether.data.AetherCredentials;
import com.threerings.orth.client.PolicyLoader;
import com.threerings.orth.client.Prefs;
import com.threerings.presents.client.Client;

import mx.core.Application;

import flash.display.Stage;
import flash.system.Capabilities;
import flash.events.ContextMenuEvent;
import flash.ui.ContextMenu;

public class AetherClient extends Client
{
    public function AetherClient (app :Application, host :String,
        ports :Array, socketPolicyPort :int)
    {
        super();

        // configure our version
        setVersion(_wctx.getVersion());

        // configure our server and port info
        setServer(host, ports);

        // and context
        _wctx = AetherContext(createContext(app));

        // because we're the ur-client, initialize the policy loader
        PolicyLoader.init(socketPolicyPort);

        // then register with it, as any client would
        PolicyLoader.registerClient(this);

        // set up a context menu that blocks funnybiz on the stage
        var menu :ContextMenu = new ContextMenu();
        menu.hideBuiltInItems();
        app.contextMenu = menu;
        menu.addEventListener(ContextMenuEvent.MENU_SELECT, contextMenuWillPopUp);
    }

    public function logonWithCredentials (creds :AetherCredentials) :Boolean
    {
        if (isLoggedOn()) {
            return false;
        }

        creds.ident = Prefs.getMachineIdent();
        setCredentials(creds);
        logon();
    }

    /**
     * Creates the context we'll use with this client.
     */
    protected function createContext (app :Application) :AetherContext
    {
        return new AetherContext(app, this);
    }

    /**
     * Creates the credentials we'll use to log on.
     */
    protected function createStartupCreds () :AetherCredentials
    {
        return new AetherCredentials("");
    }
}
}
