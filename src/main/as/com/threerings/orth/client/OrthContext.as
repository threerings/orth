//
// $Id: MsoyContext.as 18581 2009-11-04 21:35:54Z jamie $

package com.threerings.orth.client {

import flash.display.Stage;

import mx.core.UIComponent;

import com.threerings.orth.data.OrthName;
import com.threerings.util.Log;
import com.threerings.util.MessageBundle;
import com.threerings.util.MessageManager;

import com.threerings.presents.client.Client;
import com.threerings.presents.client.ConfirmAdapter;
import com.threerings.presents.client.InvocationAdapter;
import com.threerings.presents.client.InvocationService_ConfirmListener;
import com.threerings.presents.client.InvocationService_InvocationListener;
import com.threerings.presents.client.InvocationService_ResultListener;
import com.threerings.presents.client.ResultAdapter;
import com.threerings.presents.dobj.DObjectManager;

import com.threerings.crowd.client.LocationDirector;
import com.threerings.crowd.client.OccupantDirector;
import com.threerings.crowd.client.PlaceView;
import com.threerings.crowd.util.CrowdContext;

import com.threerings.crowd.chat.client.ChatDirector;

/**
 * Provides services shared by all clients.
 */
public /*abstract*/ class OrthContext
    implements CrowdContext
{
    public function OrthContext (client :OrthClient)
    {
        _client = client;

        // initialize the message manager
        _msgMgr = new MessageManager();

        _locDir = new LocationDirector(this);
        _occDir = new OccupantDirector(this);
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
        throw new Error("abstract");
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
        throw new Error("abstract");
    }

    // documentation inherited from superinterface CrowdContext
    public function setPlaceView (view :PlaceView) :void
    {
        throw new Error("abstract");
    }

    // documentation inherited from superinterface CrowdContext
    public function clearPlaceView (view :PlaceView) :void
    {
        throw new Error("abstract");
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
    public function getTokens () :MsoyTokenRing
    {
        throw new Error("abstract");
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
            Log.getLog(OrthContext).info.apply(null, args);

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
}
}
