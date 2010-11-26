//
// $Id: WorldContext.as 18724 2009-11-19 19:21:47Z jamie $

package com.threerings.orth.world.client {
import com.threerings.crowd.chat.client.ChatDirector;
import com.threerings.crowd.client.LocationDirector;
import com.threerings.crowd.client.OccupantDirector;
import com.threerings.crowd.client.PlaceView;
import com.threerings.crowd.data.BodyObject;
import com.threerings.orth.client.OrthClient;
import com.threerings.orth.data.OrthName;
import com.threerings.presents.client.Client;
import com.threerings.presents.client.ConfirmAdapter;
import com.threerings.presents.client.InvocationAdapter;
import com.threerings.presents.client.InvocationService_ConfirmListener;
import com.threerings.presents.client.InvocationService_InvocationListener;
import com.threerings.presents.client.InvocationService_ResultListener;
import com.threerings.presents.client.ResultAdapter;
import com.threerings.presents.dobj.DObjectManager;
import com.threerings.util.Log;
import com.threerings.util.MessageBundle;
import com.threerings.util.MessageManager;
import com.threerings.whirled.client.SceneDirector;
import com.threerings.whirled.spot.client.SpotSceneDirector;
import com.threerings.whirled.util.WhirledContext;

import mx.core.UIComponent;

/**
 * Defines services for the World client.
 */
public class WorldContext
    implements WhirledContext
{
    /** Contains non-persistent properties that are set in various places and can be bound to to be
     * notified when they change. */
    public var worldProps :WorldProperties = new WorldProperties();

    public function WorldContext (client :WorldClient)
    {
        super(client);

        _client = client;

        // initialize the message manager
        _msgMgr = new MessageManager();

        _locDir = new LocationDirector(this);
        _occDir = new OccupantDirector(this);

        _sceneDir = new MsoySceneDirector(this, _locDir, new RuntimeSceneRepository());
        _spotDir = new SpotSceneDirector(this, _locDir, _sceneDir);
        _worldDir = new WorldDirector(this);
        _memberDir = new MemberDirector(this);
        _partyDir = new PartyDirector(this);

        // some directors we create here (unsuppressed)
        _mediaDir = new MediaDirector(this);
        _controller = new WorldController(this, _topPanel);
    }

    /**
     * Get the width of the client.
     * By default this is just the stage width, but that should not be assumed!
     * Certain subclasses override this method and in the future it could become
     * more complicated due to embedding.
     */
    public function getWidth () :Number
    {
        return _client.getStage().stageWidth;
    }

    /**
     * Get the height of the client. Please review the the notes in getWidth().
     */
    public function getHeight () :Number
    {
        return _client.getStage().stageHeight;
    }

    public function getStage () :Stage
    {
        return _client.getStage();
    }

    /**
     * Returns our client as its OrthClient self.
     */
    public function getOrthClient () :OrthClient
    {
        return _client;
    }

    /**
     * Create an InvocationListener that will automatically log and report errors to chat.
     *
     * @param bundle the MessgeBundle to use to translate the error message.
     * @param errWrap if not null, a translation key used to report the error, with the
     *        'cause' String from the server as it's argument.
     * @param logArgs arguments to use when logging the error. An even number of arguments
     *        may be specified in the "description", value, "description", value format.
     *        Specifying an odd number of arguments uses the first arg as the primary log message,
     *        instead of something generic like "An error occurred".
     */
    public function listener (bundle:String, errWrap :String = null, ... logArgs)
        :InvocationService_InvocationListener
    {
        return new InvocationAdapter(chatErrHandler(bundle, errWrap, null, logArgs));
    }

    /**
     * Create a ConfirmListener that will automatically log and report errors to chat.
     *
     * @param confirm if a String, a message that will be reported on success. If a function,
     *        it will be run on success.
     * @param component if non-null, a component that will be disabled, and re-enabled when
     *        the response arrives from the server (success or failure).
     * @see listener() for a description of the rest of the arguments.
     */
    public function confirmListener (bundle :String, confirm :* = null, errWrap :String = null,
        component :UIComponent = null, ... logArgs)
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

    /**
     * Create a ResultListener that will automatically log and report errors to chat.
     *
     * @param gotResult a function that will be passed a single result argument from the server.
     * @param component if non-null, a component that will be disabled, and re-enabled when
     *        the response arrives from the server (success or failure).
     * @see listener() for a description of the rest of the arguments.
     */
    public function resultListener (bundle :String, gotResult :Function, errWrap :String = null,
        component :UIComponent = null, ... logArgs)
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

    /**
     * Convenience method.
     */
    public function displayFeedback (bundle :String, message :String) :void
    {
        getChatDirector().displayFeedback(bundle, message);
    }

    /**
     * Convenience method.
     */
    public function displayInfo (bundle :String, message :String, localType :String = null) :void
    {
        getChatDirector().displayInfo(bundle, message, localType);
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

    // documentation inherited from superinterface CrowdContext
    public function setPlaceView (view :PlaceView) :void
    {
        _topPanel.setPlaceView(view);
    }

    // documentation inherited from superinterface CrowdContext
    public function clearPlaceView (view :PlaceView) :void
    {
        _topPanel.clearPlaceView(view);
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
        return (name == null) ? 0 : name.getMemberId();
    }

    /**
     * Returns this client's access control tokens.
     */
    public function getTokens () :OrthTokenRing
    {
        // if we're not logged on, claim to have no privileges
        return (getMemberObject() == null) ? new OrthTokenRing() : getMemberObject().tokens;
    }

    // from WhirledContext
    public function getSceneDirector () :SceneDirector
    {
        return _sceneDir;
    }

    /**
     * Convenience method.
     */
    public function getMemberObject () :MemberObject
    {
        return (_client.getClientObject() as MemberObject);
    }

    /**
     * Returns our client casted to a WorldClient.
     */
    public function getWorldClient () :WorldClient
    {
        return (getClient() as WorldClient);
    }

    /**
     * Get the media director.
     */
    public function getMediaDirector () :MediaDirector
    {
        return _mediaDir;
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
     * Get the MemberDirector.
     */
    public function getMemberDirector () :MemberDirector
    {
        return _memberDir;
    }

    /**
     * Get the party director.
     */
    public function getPartyDirector () :PartyDirector
    {
        return _partyDir;
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

    protected var _client :OrthClient;

    protected var _msgMgr :MessageManager;
    protected var _locDir :LocationDirector;
    protected var _occDir :OccupantDirector;

    protected var _controller :WorldController;

    protected var _sceneDir :SceneDirector;
    protected var _spotDir :SpotSceneDirector;
    protected var _mediaDir :MediaDirector;
    protected var _worldDir :WorldDirector;
    protected var _memberDir :MemberDirector;
    protected var _partyDir :PartyDirector;
}
}
