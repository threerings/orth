//
// $Id$

package com.threerings.orth.aether.client {

import com.threerings.presents.client.Client;

import mx.core.Application;

import flash.display.Stage;

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

        // now create our credentials
        var creds :Credentials = createStartupCreds();
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
        log.info("Starting up", "capabilities", Capabilities.serverString);

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
     * Creates the context we'll use with this client.
     */
    protected function createContext () :AetherContext
    {
        return new AetherContext(this);
    }

    protected function createStartupCreds () :AetherCredentials
    {
        
    }
}
}
