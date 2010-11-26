//
// $Id: WorldClient.as 19262 2010-07-13 22:28:11Z zell $

package com.threerings.orth.world.client {
import com.threerings.orth.client.ContextMenuProvider;
import com.threerings.orth.client.OrthClient;
import com.threerings.orth.data.OrthName;
import com.threerings.orth.world.client.WorldContext;
import com.threerings.orth.client.PlaceBox;
import com.threerings.orth.client.Prefs;
import com.threerings.orth.data.UberClientModes;
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
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.dobj.DObjectManager;
import com.threerings.presents.net.BootstrapData;
import com.threerings.presents.net.Credentials;

import com.threerings.whirled.data.Scene;


/**
 * Handles the main services for the world and game clients.
 */
public class WorldClient extends OrthClient
{
    WorldMarshaller; // static reference for deserialization

    public function WorldClient (stage :Stage)
    {
        super(stage);

        // TODO: allow users to choose? I think it's a decision that we should make for them.
        // Jon speculates that maybe we can monitor the frame rate and automatically shift it,
        // but noticable jiggles occur when it's switched and I wouldn't want the entire
        // world to jiggle when someone starts walking, then jiggle again when they stop.
        // So: for now we just peg it to MEDIUM.
        stage.quality = StageQuality.MEDIUM;

        _wctx = new WorldContext(this);

        // if we are embedded, we won't have a server host in our parameters, so we need to obtain
        // that via an HTTP request, otherwise just logon directly
        var params :Object = MsoyParameters.get();

        // if we're an embedded client, turn on the embed header
        if (isEmbedded()) {
            _wctx.getUIState().setEmbedded(true);
        }

        _minimized = params["minimized"] != null;

        if (getHostname() == null) {
            var loader :URLLoader = new URLLoader();
            var worldClient :WorldClient = this;
            loader.addEventListener(Event.COMPLETE, function () :void {
                loader.removeEventListener(Event.COMPLETE, arguments.callee);
                var bits :Array = (loader.data as String).split(":");
                setServer(bits[0], [ int(bits[1]) ]);
                GuestSessionCapture.capture(worldClient);
                logon();
            });
            // TODO: add listeners for failure events? give feedback on failure?

            // embedded clients should link to a particular scene (or game in which case we'll just
            // connect to any old world server)
            var sceneId :int = int(params["sceneId"]);
            var url :String = DeploymentConfig.serverURL + "embed/" +
                (sceneId == 0 ? "" : ("s"+sceneId));
            loader.load(new URLRequest(url));
            log.info("Loading server info from " + url + ".");

        } else {
            GuestSessionCapture.capture(this);
            logon();
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
     * Exposed to javascript so that it may notify us to logon.
     */
    protected function externalClientLogon (memberId :int, token :String) :void
    {
        if (token == null) {
            return;
        }

        // if we're logged into the world server or game server already with this id, ignore
        if (memberId == _wctx.getMyId()) {
            return;
        }

        log.info("Logging on via external request", "id", memberId, "token", token);
        _wctx.getWorldController().handleLogon(createStartupCreds(token));
    }

    // from MsoyClient
    override protected function configureExternalFunctions () :void
    {
        super.configureExternalFunctions();

        ExternalInterface.addCallback("clientLogon", externalClientLogon);
    }

    // from MsoyClient
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

    // from MsoyClient
    override protected function createStartupCreds (token :String) :Credentials
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
        creds.visitorId = getVisitorId();
        creds.affiliateId = getAffiliateId();
        creds.vector = getEntryVector();

        // if we're anonymous and in an embed and have no visitor id we need to generate one
        if (creds.sessionToken == null && anonymous && creds.visitorId == null) {
            creds.visitorId = VisitorInfo.createLocalId();
            log.info("Created local visitorId", "visitorId", creds.visitorId);
        }

        return creds;
    }

    protected var _wctx :WorldContext;

    private static const log :Log = Log.getLog(WorldClient);
}
}
