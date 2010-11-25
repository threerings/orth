//
// $Id: WorldClient.as 19262 2010-07-13 22:28:11Z zell $

package com.threerings.orth.world.client {
import com.threerings.orth.client.ContextMenuProvider;
import com.threerings.orth.client.OrthClient;
import com.threerings.orth.client.OrthContext;
import com.threerings.orth.client.PlaceBox;
import com.threerings.orth.client.Prefs;
import com.threerings.orth.data.UberClientModes;
import com.threerings.orth.room.client.RoomObjectView;

import flash.display.DisplayObject;
import flash.display.Stage;
import flash.display.StageQuality;
import flash.events.Event;
import flash.events.IEventDispatcher;
import flash.external.ExternalInterface;
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

        // if we are embedded, we won't have a server host in our parameters, so we need to obtain
        // that via an HTTP request, otherwise just logon directly
        var params :Object = MsoyParameters.get();

        // if we're an embedded client, turn on the embed header
        if (isEmbedded() && !_featuredPlaceView) {
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

        if (_featuredPlaceView) {
            var overlay :FeaturedPlaceOverlay = new FeaturedPlaceOverlay(_ctx);
            _ctx.getTopPanel().getPlaceContainer().addOverlay(
                overlay, PlaceBox.LAYER_FEATURED_PLACE);
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

    // from Client
    override public function gotClientObject (clobj :ClientObject) :void
    {
        super.gotClientObject(clobj);

        var member :MemberObject = clobj as MemberObject;
        if (_featuredPlaceView || member == null) {
            return;
        }

        // listen for theme changes
        var themeUpdater :ThemeUpdater = new ThemeUpdater(this);
        member.addListener(themeUpdater);
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
        _wctx.getMsoyController().handleLogon(createStartupCreds(token));
    }

    /**
     * Exposed to javascript so that it may notify us to move to a new location.
     */
    protected function externalClientGo (where :String) :Boolean
    {
        if (_wctx.getClient().isLoggedOn()) {
            log.info("Changing scenes per external request", "where", where);
            _wctx.getWorldController().goToPlace(new URLVariables(where));
            return true;
        } else {
            log.info("Not ready to change scenes (we're not logged on)", "where", where);
            return false;
        }
    }

    /**
     * Exposed to javascript so that the it may determine if the current scene is a room.
     */
    protected function externalInRoom () :Boolean
    {
        return _wctx.getPlaceView() is RoomObjectView;
    }

    /**
     * Exposed to javascript so that the it may determine if the scene id.
     */
    protected function externalGetSceneId () :int
    {
        var scene :Scene = _wctx.getSceneDirector().getScene();
        return (scene == null) ? 0 : scene.getId();
    }

    /**
     * Exposed to javascript so that it may tell us to use this avatar.  If the avatarId of 0 is
     * passed in, the current avatar is simply cleared away, leaving them with the default.
     */
    protected function externalUseAvatar (avatarId :int) :void
    {
        _wctx.getWorldDirector().setAvatar(avatarId);
    }

    /**
     * Exposed to javascript so that the avatarviewer may update the scale of an avatar
     * in real-time.
     */
    protected function externalUpdateAvatarScale (avatarId :int, newScale :Number) :void
    {
        var view :RoomObjectView = _wctx.getPlaceView() as RoomObjectView;
        if (view != null) {
            view.updateAvatarScale(avatarId, newScale);
        }
    }

    /**
     * Exposed to javascript so that it may tell us to use items in the current room, either as
     * background items, or as furni as apporpriate.
     */
    protected function externalUseItem (itemType :int, itemId :int) :void
    {
        var view :RoomObjectView = _wctx.getPlaceView() as RoomObjectView;
        if (view != null) {
            view.getRoomObjectController().useItem(itemType, itemId);
        }
    }

    /**
     * Exposed to javascript so that it may tell us to remove an item from use.
     */
    protected function externalClearItem (itemType :int, itemId :int) :void
    {
        var view :RoomObjectView = _wctx.getPlaceView() as RoomObjectView;
        if (view != null) {
            view.getRoomObjectController().clearItem(itemType, itemId);
        }
    }

    /**
     * Exposed to JavaScript so that it may order us to open chat channels.
     */
    protected function externalOpenChannel (type :int, name :String, id :int) :void
    {
        var nameObj :Name;
        if (type == MsoyChatChannel.MEMBER_CHANNEL) {
            nameObj = new MemberName(name, id);
        } else if (type == MsoyChatChannel.GROUP_CHANNEL) {
            nameObj = new GroupName(name, id);
        } else if (type == MsoyChatChannel.PRIVATE_CHANNEL) {
            nameObj = new ChannelName(name, id);
        } else {
            throw new Error("Unknown channel type: " + type);
        }
        _wctx.getMsoyChatDirector().openChannel(nameObj);
    }

    // from MsoyClient
    override protected function configureBridgeFunctions (dispatcher :IEventDispatcher) :void
    {
        super.configureBridgeFunctions(dispatcher);
        dispatcher.addEventListener(UberClientModes.GOT_EXTERNAL_NAME, bridgeGotExternalName);
    }

    /**
     * Called when the embedstub obtains a display name from the external site on which we're
     * embedded. We use this to replace "Guest XXXX" for permaguests with their external site name.
     */
    protected function bridgeGotExternalName (event :Event) :void
    {
        var name :String = event["info"]; // EmbedStub.BridgeEvent.info via security boundary
        log.info("Got external name", "name", name);
        function maybeConfigureGuest () :void {
            if (_wctx.getMemberObject().isPermaguest()) {
                log.info("Using external name", "name", name);
                _wctx.getMemberDirector().setDisplayName(name);
            }
        }
        if (_wctx.getClient().isLoggedOn()) {
            maybeConfigureGuest();
        } else {
            var adapter :ClientAdapter = new ClientAdapter(null, function (event :*) :void {
                _wctx.getClient().removeClientObserver(adapter);
                maybeConfigureGuest();
            });
            _wctx.getClient().addClientObserver(adapter);
        }
    }

    // from MsoyClient
    override protected function createContext () :OrthContext
    {
        return (_wctx = new WorldContext(this));
    }

    // from MsoyClient
    override protected function configureExternalFunctions () :void
    {
        super.configureExternalFunctions();

        ExternalInterface.addCallback("clientLogon", externalClientLogon);
        ExternalInterface.addCallback("clientGo", externalClientGo);
        ExternalInterface.addCallback("inRoom", externalInRoom);
        ExternalInterface.addCallback("getSceneId", externalGetSceneId);
        ExternalInterface.addCallback("useAvatar", externalUseAvatar);
        ExternalInterface.addCallback("updateAvatarScale", externalUpdateAvatarScale);
        ExternalInterface.addCallback("useItem", externalUseItem);
        ExternalInterface.addCallback("clearItem", externalClearItem);
        ExternalInterface.addCallback("openChannel", externalOpenChannel);
    }

    // from MsoyClient
    override protected function populateContextMenu (custom :Array) :void
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

        } else if (Prefs.getPermaguestUsername() != null) {
            creds = new WorldCredentials(new Name(Prefs.getPermaguestUsername()), "");
            anonymous = false;

        } else {
            creds = new WorldCredentials(null, null);
            anonymous = true;
        }

        creds.sessionToken = (token == null) ? params["token"] : token;
        creds.themeId = params["themeId"];
        creds.ident = Prefs.getMachineIdent();
        creds.featuredPlaceView = _featuredPlaceView;
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
