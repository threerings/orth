//
// $Id$

package com.threerings.orth.aether.client {
import com.threerings.presents.data.ClientObject;

import flash.display.DisplayObject;
import flash.display.Stage;
import flash.events.ContextMenuEvent;
import flash.geom.Point;
import flash.system.Capabilities;
import flash.ui.ContextMenu;
import flash.utils.Dictionary;

import flashx.funk.ioc.inject;

import com.threerings.ui.MenuUtil;

import com.threerings.util.Log;

import com.threerings.presents.client.Client;
import com.threerings.presents.dobj.DObjectManager;
import com.threerings.presents.net.BootstrapData;

import com.threerings.orth.aether.data.AetherAuthResponseData;
import com.threerings.orth.aether.data.AetherCredentials;
import com.threerings.orth.aether.data.PlayerObject;
import com.threerings.orth.client.ContextMenuProvider;
import com.threerings.orth.client.Msgs;
import com.threerings.orth.client.OrthController;
import com.threerings.orth.client.OrthDeploymentConfig;
import com.threerings.orth.client.PolicyLoader;
import com.threerings.orth.client.Prefs;
import com.threerings.orth.data.AuthName;

public class AetherClient extends Client
{
    // reference classes that would otherwise not be linked in
    AuthName;
    PlayerObject;

    public function AetherClient ()
    {
        const depConf :OrthDeploymentConfig = inject(OrthDeploymentConfig);

        // configure our server and port info
        setServer(depConf.host, depConf.ports);

        // then register with it, as any client would
        PolicyLoader.registerClient(this, depConf.policyPort);
        // configure our version
        setVersion(depConf.version);

        // TODO - reenable without Application for non-flex clients
        // set up a context menu that blocks funnybiz on the stage
        //var menu :ContextMenu = new ContextMenu();
        //menu.hideBuiltInItems();
        //menu.addEventListener(ContextMenuEvent.MENU_SELECT, contextMenuWillPopUp);
        //inject(Application).contextMenu = menu;
    }

    public function getPlayerObject () :PlayerObject
    {
        return _plobj;
    }

    public function logonWithCredentials (creds :AetherCredentials) :Boolean
    {
        if (isLoggedOn()) {
            return false;
        }

        creds.ident = Prefs.getMachineIdent();
        setCredentials(creds);
        logon();
        return true;
    }

    // from Client
    override public function gotBootstrap (data :BootstrapData, omgr :DObjectManager) :void
    {
        super.gotBootstrap(data, omgr);

        // save any machineIdent or sessionToken from the server.
        var rdata :AetherAuthResponseData = AetherAuthResponseData(getAuthResponseData());
        if (rdata.ident != null) {
            Prefs.setMachineIdent(rdata.ident);
        }
        if (rdata.sessionToken != null) {
            // TODO - scoped injection
            //_injector.mapValue(String, rdata.sessionToken, "sessionToken");
        }
    }

    override public function gotClientObject (clobj :ClientObject):void
    {
        super.gotClientObject(clobj);

        _plobj = PlayerObject(clobj);
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
            Msgs.GENERAL.get("b.about"), OrthController.ABOUT, null, useSep));

        // then, the menu will pop up
    }

    protected function populateContextMenu (custom :Array) :void
    {
        try {
            var allObjs :Array = _stage.getObjectsUnderPoint(new Point(_stage.mouseX, _stage.mouseY));
            var seen :Dictionary = new Dictionary();
            for each (var disp :DisplayObject in allObjs) {
                try {
                    while (disp != null && !(disp in seen)) {
                        seen[disp] = true;
                        if (disp is ContextMenuProvider) {
                            (disp as ContextMenuProvider).populateContextMenu(custom);
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

    protected var _plobj :PlayerObject;

    protected const _stage :Stage = inject(Stage);

    private static const log :Log = Log.getLog(AetherClient);
}
}
