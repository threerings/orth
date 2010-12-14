package com.threerings.orth.client
{
import com.threerings.crowd.chat.client.MuteDirector;
import com.threerings.orth.chat.client.OrthChatDirector;
import com.threerings.orth.notify.client.NotificationDirector;
import com.threerings.orth.party.client.PartyDirector;
import com.threerings.orth.room.client.MediaDirector;
import com.threerings.orth.data.OrthCodes;
import com.threerings.orth.data.OrthName;
import com.threerings.presents.client.InvocationService_ConfirmListener;
import com.threerings.presents.client.InvocationService_InvocationListener;
import com.threerings.presents.client.InvocationService_ResultListener;
import com.threerings.presents.net.AuthResponseData;
import com.threerings.presents.util.PresentsContext;

import mx.core.Application;
import mx.core.UIComponent;

import flash.display.Stage;

public interface OrthContext
    extends PresentsContext
{
    /**
     * Return the compiled version identifier for this client. This value is sent over the wire
     * to validate with the server.
     */
    function getVersion () :String;

    /**
     * Get the width of the client.
     * By default this is just the stage width, but that should not be assumed!
     * Certain subclasses override this method and in the future it could become
     * more complicated due to embedding.
     */
    function getWidth () :Number;

    /**
     * Get the height of the client. Please review the the notes in getWidth().
     */
    function getHeight () :Number;

    /**
     * Return a reference to our Stage.
     */
    function getStage () :Stage;

    /**
     * Return a reference to our Application.
     */
    function getApplication () :Application;

    /**
     * Saves the session token communicated via the supplied auth response. It is stored in the
     * credentials of the client so that we can log in more efficiently on a reconnect, and so that
     * we can log into game servers.
     */
    function saveSessionToken (arsp :AuthResponseData) :void;

    /**
     * Return's this client's member name, or null if we're not logged in.
     */
    function getMyName () :OrthName;

    /**
     * Return this client's member id, or 0 if we're logged off.
     */
    function getMyId () :int;

    /**
     * Let us know whether or not this is a development environment.
     */
    function isDevelopment () :Boolean;

    /**
     * Returns a reference to the top-level UI container.
     */
    function getTopPanel () :TopPanel;

    /**
     * Return a casted reference to our {@link orthChatDirector}.
     */
    function getOrthChatDirector () :OrthChatDirector;

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
    function listener (bundle :String = OrthCodes.GENERAL_MSGS,
        errWrap :String = null, ... logArgs) :InvocationService_InvocationListener;

    /**
     * Create a ConfirmListener that will automatically log and report errors to chat.
     *
     * @param confirm if a String, a message that will be reported on success. If a function,
     *        it will be run on success.
     * @param component if non-null, a component that will be disabled, and re-enabled when
     *        the response arrives from the server (success or failure).
     * @see listener() for a description of the rest of the arguments.
     */
    function confirmListener (bundle :String = OrthCodes.GENERAL_MSGS, confirm :* = null,
        errWrap :String = null, component :UIComponent = null, ... logArgs)
        :InvocationService_ConfirmListener;

    /**
     * Create a ResultListener that will automatically log and report errors to chat.
     *
     * @param gotResult a function that will be passed a single result argument from the server.
     * @param component if non-null, a component that will be disabled, and re-enabled when
     *        the response arrives from the server (success or failure).
     * @see listener() for a description of the rest of the arguments.
     */
    function resultListener (gotResult :Function, bundle :String = OrthCodes.GENERAL_MSGS,
        errWrap :String = null, component :UIComponent = null, ... logArgs)
        :InvocationService_ResultListener;

    /**
     * Convenience method.
     */
    function displayFeedback (bundle :String, message :String) :void;

    /**
     * Convenience method.
     */
    function displayInfo (bundle :String, message :String, localType :String = null) :void;

    /**
     * Return a reference to our {@link MuteDirector}.
     */
    function getMuteDirector () :MuteDirector;

    /**
     * Get the media director.
     */
    function getMediaDirector () :MediaDirector;

    /**
     * Get the party director.
     */
    function getPartyDirector () :PartyDirector;

    /**
     * Get the notification director.
     */
    function getNotificationDirector () :NotificationDirector;
}
}
