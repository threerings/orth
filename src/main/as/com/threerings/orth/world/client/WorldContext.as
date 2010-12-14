//
// $Id: WorldContext.as 18724 2009-11-19 19:21:47Z jamie $

package com.threerings.orth.world.client {
import com.threerings.crowd.chat.client.ChatDirector;
import com.threerings.crowd.chat.client.MuteDirector;
import com.threerings.crowd.util.CrowdContext;
import com.threerings.crowd.client.LocationDirector;
import com.threerings.crowd.client.OccupantDirector;
import com.threerings.crowd.client.PlaceView;
import com.threerings.crowd.data.BodyObject;
import com.threerings.orth.chat.client.OrthChatDirector;
import com.threerings.orth.client.ControlBar;
import com.threerings.crowd.data.TokenRing;
import com.threerings.orth.client.OrthContext;
import com.threerings.orth.client.TopPanel;
import com.threerings.orth.data.OrthCodes;
import com.threerings.orth.data.OrthCredentials;
import com.threerings.orth.data.OrthName;
import com.threerings.orth.data.PlayerObject;
import com.threerings.orth.party.client.PartyDirector;
import com.threerings.orth.room.client.MediaDirector;
import com.threerings.orth.room.client.OrthSceneDirector;
import com.threerings.orth.notify.client.NotificationDirector;
import com.threerings.orth.room.client.persist.RuntimeSceneRepository;
import com.threerings.presents.client.Client;
import com.threerings.presents.client.ConfirmAdapter;
import com.threerings.presents.client.InvocationAdapter;
import com.threerings.presents.client.InvocationService_ConfirmListener;
import com.threerings.presents.client.InvocationService_InvocationListener;
import com.threerings.presents.client.InvocationService_ResultListener;
import com.threerings.presents.client.ResultAdapter;
import com.threerings.presents.dobj.DObjectManager;
import com.threerings.presents.net.AuthResponseData;
import com.threerings.util.Log;
import com.threerings.util.MessageBundle;
import com.threerings.util.MessageManager;
import com.threerings.whirled.client.SceneDirector;
import com.threerings.whirled.spot.client.SpotSceneDirector;
import com.threerings.whirled.util.WhirledContext;

import mx.core.Application;
import mx.core.UIComponent;

import flash.display.Stage;

import com.threerings.orth.data.OrthAuthResponseData;

/**
 * Defines services for the World client.
 */
public class WorldContext
    implements WhirledContext, OrthContext
{
    public function WorldContext (client :WorldClient)
    {
        _client = client;

        // initialize the message manager
        _msgMgr = new MessageManager();

        _locDir = new LocationDirector(this);
        _occDir = new OccupantDirector(this);
        _chatDir = new OrthChatDirector(this);

        // the top panel's constructor will add it to the app's UI hierarchy
        _topPanel = new TopPanel(this, createControlBar());

        // we create some of our directors in a method that can be overridden
        createAdditionalDirectors();

        // some directors we create here (unsuppressed)
        _mediaDir = new MediaDirector(this);
        _controller = new WorldController(this, _topPanel);
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

    // from OrthContext
    public function getWidth () :Number
    {
        return _client.getStage().stageWidth;
    }

    // from OrthContext
    public function getHeight () :Number
    {
        return _client.getStage().stageHeight;
    }

    // from OrthContext
    public function getStage () :Stage
    {
        return _client.getStage();
    }

    public function getApplication () :Application
    {
        return _client.getApplication();
    }

    /**
     * Returns our client as its WorldClient self.
     */
    public function getWorldClient () :WorldClient
    {
        return _client;
    }

    // from OrthContext
    public function saveSessionToken (arsp :AuthResponseData) :void
    {
        var rdata :OrthAuthResponseData = (arsp as OrthAuthResponseData);
        if (rdata.sessionToken != null) {
            Log.getLog(OrthContext).info("Using session token " + rdata.sessionToken);
            OrthCredentials(getClient().getCredentials()).sessionToken = rdata.sessionToken;
        }
    }

    // from OrthContext
    public function isDevelopment ():Boolean
    {
        return true;
    }

    // from OrthContext
    public function getVersion () :String
    {
        return "DEV";
    }

    // from OrthContext
    public function getTopPanel () :TopPanel
    {
        return _topPanel;
    }

    // from OrthContext
    public function getOrthChatDirector () :OrthChatDirector
    {
        return null;
    }

    // from OrthContext
    public function listener (bundle :String = OrthCodes.GENERAL_MSGS,
        errWrap :String = null, ... logArgs) :InvocationService_InvocationListener
    {
        return new InvocationAdapter(chatErrHandler(bundle, errWrap, null, logArgs));
    }

    // from OrthContext
    public function confirmListener (bundle :String = OrthCodes.GENERAL_MSGS, confirm :* = null,
        errWrap :String = null, component :UIComponent = null, ... logArgs)
        :InvocationService_ConfirmListener
    {
        var success :Function = function () :void {
            if (component != null) {
                component.enabled = true;
            }
            if (confirm is Function) {
                (confirm as Function)();
            } else if (confirm is String) {
                displayFeedback(bundle, String(confirm));
            }
        };
        if (component != null) {
            component.enabled = false;
        }
        return new ConfirmAdapter(success, chatErrHandler(bundle, errWrap, component, logArgs));
    }

    // from OrthContext
    public function resultListener (gotResult :Function, bundle :String = OrthCodes.GENERAL_MSGS,
        errWrap :String = null, component :UIComponent = null, ... logArgs)
        :InvocationService_ResultListener
    {
        var success :Function;
        if (component == null) {
            success = gotResult;
        } else {
            component.enabled = false;
            success = function (result :Object) :void {
                component.enabled = true;
                gotResult(result);
            };
        }
        return new ResultAdapter(success, chatErrHandler(bundle, errWrap, component, logArgs));
    }

    // from OrthContext
    public function displayFeedback (bundle :String, message :String) :void
    {
        getChatDirector().displayFeedback(bundle, message);
    }

    // from OrthContext
    public function displayInfo (bundle :String, message :String, localType :String = null) :void
    {
        getChatDirector().displayInfo(bundle, message, localType);
    }

    // from OrthContext
    public function getMuteDirector () :MuteDirector
    {
        return _muteDir;
    }

    // from OrthContext
    public function getMediaDirector () :MediaDirector
    {
        return _mediaDir;
    }

    // from OrthContext
    public function getPartyDirector () :PartyDirector
    {
        return _partyDir;
    }

    // from OrthContext
    public function getNotificationDirector () :NotificationDirector
    {
        return _notifyDir;
    }

    // from CrowdContext
    public function getLocationDirector () :LocationDirector
    {
        return _locDir;
    }

    // from CrowdContext
    public function getOccupantDirector () :OccupantDirector
    {
        return _occDir;
    }

    // from CrowdContext
    public function getChatDirector () :ChatDirector
    {
        // let's see if we can get away with this
        return null;
    }

    /**
     * Get the message manager.
     */
    public function getMessageManager () :MessageManager
    {
        return _msgMgr;
    }

    /**
     * Return the current PlaceView.
     */
    public function getPlaceView () :PlaceView
    {
        return _topPanel.getPlaceView();
    }

    // from CrowdContext
    public function setPlaceView (view :PlaceView) :void
    {
        _topPanel.setPlaceView(view);
    }

    // from CrowdContext
    public function clearPlaceView (view :PlaceView) :void
    {
        _topPanel.clearPlaceView(view);
    }

    // from WhirledContext
    public function getSceneDirector () :SceneDirector
    {
        return _sceneDir;
    }

    /**
     * Return's this client's member name.
     */
    public function getMyName () :OrthName
    {
        var body :BodyObject = (_client.getClientObject() as BodyObject);
        return (body == null) ? null : body.getVisibleName() as OrthName;
    }

    /**
     * Return this client's member id, or 0 if we're logged off or the viewer.
     */
    public function getMyId () :int
    {
        var name :OrthName = getMyName();
        return (name == null) ? 0 : name.getId();
    }

    /**
     * Returns this client's access control tokens.
     */
    public function getTokens () :TokenRing
    {
        // if we're not logged on, claim to have no privileges
        return new TokenRing();
    }

    /**
     * Convenience method.
     */
    public function getPlayerObject () :PlayerObject
    {
        return (_client.getClientObject() as PlayerObject);
    }

    /**
     * Get the WorldDirector.
     */
    public function getWorldDirector () :WorldDirector
    {
        return _worldDir;
    }

    /**
     * Get the SpotSceneDirector.
     */
    public function getSpotSceneDirector () :SpotSceneDirector
    {
        return _spotDir;
    }

    /**
     * Returns the top-level world controller.
     */
    public function getWorldController () :WorldController
    {
        return _controller;
    }

    /**
     * Returns the world control bar.
     */
    public function getWorldControlBar () :WorldControlBar
    {
        return WorldControlBar(_topPanel.getControlBar());
    }

    /**
     * Returns the world control bar.
     */
    public function getControlBar () :ControlBar
    {
        return _topPanel.getControlBar();
    }

    /**
     * Create extra directors that we may want to suppress in certain subclasses.
     */
    protected function createAdditionalDirectors () :void
    {
        _notifyDir = new NotificationDirector(this, PlayerObject.NOTIFICATION);
        _sceneDir = new OrthSceneDirector(this, _locDir, new RuntimeSceneRepository());
        _spotDir = new SpotSceneDirector(this, _locDir, _sceneDir);
        _worldDir = new WorldDirector(this);
        _partyDir = new PartyDirector(this);
        _muteDir = new MuteDirector(this);
    }

    /**
     * Create an error handling function for use with InvocationService listener adapters.
     */
    protected function chatErrHandler (
        bundle :String, errWrap :String, component :UIComponent, logArgs :Array) :Function
    {
        return function (cause :String) :void {
            if (component != null) {
                component.enabled = true;
            }
            var args :Array = logArgs.concat("cause", cause); // make a copy, we're reentrant
            if (args.length % 2 == 0) {
                args.unshift("Reporting failure");
            }
            Log.getLog(WorldContext).info.apply(null, args);

            if (errWrap != null) {
                cause = MessageBundle.compose(errWrap, cause);
            }
            displayFeedback(bundle, cause);
        };
    }

    /**
     * Creates a potentially custom version of our control bar.
     */
    protected function createControlBar () :ControlBar
    {
        return new ControlBar(this);
    }

    protected var _client :WorldClient;
    protected var _topPanel :TopPanel;

    protected var _msgMgr :MessageManager;
    protected var _locDir :LocationDirector;
    protected var _occDir :OccupantDirector;
    protected var _chatDir :OrthChatDirector;

    protected var _controller :WorldController;

    protected var _notifyDir :NotificationDirector;
    protected var _sceneDir :SceneDirector;
    protected var _spotDir :SpotSceneDirector;
    protected var _mediaDir :MediaDirector;
    protected var _worldDir :WorldDirector;
    protected var _partyDir :PartyDirector;
    protected var _muteDir: MuteDirector;
}
}
