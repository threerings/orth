//
// $Id$

package com.threerings.orth.client {
import flashx.funk.ioc.inject;

import mx.core.UIComponent;

import com.threerings.util.Log;
import com.threerings.util.MessageBundle;
import com.threerings.util.MessageManager;
import com.threerings.util.Name;

import com.threerings.presents.client.Client;
import com.threerings.presents.client.ConfirmAdapter;
import com.threerings.presents.client.InvocationAdapter;
import com.threerings.presents.client.InvocationService_ConfirmListener;
import com.threerings.presents.client.InvocationService_InvocationListener;
import com.threerings.presents.client.InvocationService_ResultListener;
import com.threerings.presents.client.ResultAdapter;
import com.threerings.presents.dobj.DObjectManager;
import com.threerings.presents.util.PresentsContext;

import com.threerings.orth.aether.client.AetherClient;
import com.threerings.orth.aether.data.AetherCredentials;
import com.threerings.orth.aether.data.PlayerName;
import com.threerings.orth.aether.data.PlayerObject;
import com.threerings.orth.data.OrthCodes;
import com.threerings.orth.world.client.WorldContext;

/**
 * This is the beating heart of an Orth-based client. It provides access to the Aether client
 * and its associated distributed object manager along with all the directors responsible for
 * the services that take place over the Aether link.
 *
 * Whenever the player is in a world location, this context additionally returns a non-null
 * reference to a {@link WorldContext}, which is the nexus of the entirely distinct other half
 * of the client's workings: a separate client connected to its own server and distributed object
 * system and, consequently, a different set of directors to take advantage of it all.
 *
 * Never confuse the two contexts. They represent different systems. This one is primary, in that
 * there is always an {@link OrthContext} and always an {@link AetherClient}, but only some of
 * the time is that true for {@link WorldContext} and {@link WorldClient}.
 */
public class OrthContext
    implements PresentsContext
{
    public function OrthContext ()
    {
        // initialize our convenience holder
        Msgs.init(inject(MessageManager));
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

    /**
     * Return a reference to the current {@link WorldContext}, or null if the player is
     * not currently in a location.
     */
    public function get wctx () :WorldContext
    {
        return _wctx;
    }

    /**
     * Returns our connected {@link PlayerObject}, or null if we are not logged on.
     */
    public function getPlayerObject () :PlayerObject
    {
        return (_client != null) ? _client.getPlayerObject() : null;
    }

    /** For convenience, return our current display name. */
    public function getMyName () :PlayerName
    {
        var player :PlayerObject = getPlayerObject();
        return (player != null) ? player.playerName : null;
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
// ORTH TODO
//        getChatDirector().displayFeedback(bundle, message);
    }

    // from OrthContext
    public function displayInfo (bundle :String, message :String, localType :String = null) :void
    {
// ORTH TODO
//        getChatDirector().displayInfo(bundle, message, localType);
    }

    /**
     * To be explicitly called when we've created a {@link WorldContext} with a {@link WorldClient}
     * and are about to log into the corresponding world server.
     */
    public function enterWorld (ctxClass :Class, hostname :String, ports :Array) :void
    {
        if (_wctx != null) {
            log.error("Aii! Being given a new world context with an old one in place!");
            // but let it happen
        }

        // for now, fish our username out of our aether creds. should always be correct,
        // but possibly not the most elegant

        var username :Name = AetherCredentials(_client.getCredentials()).getUsername();

        // create (but do not inject) the concrete WorldContext subclass we were given
        _wctx = new ctxClass();

        // configure the host/ports to connect to
        //_injector.mapValue(String, hostname, "worldHostname");
        //_injector.mapValue(Array, ports, "worldPorts");

        //// map WorldClass to our instance for the duration of this world session
        //_injector.mapValue(WorldContext, _wctx);

        //// and perform injection, bootstrapping the world logon proceure
        //_wctx = _injector.getInstance(ctxClass);
    }

    /**
     * To be explicitly called when we've finished leaving a world location.
     */
    public function leftWorld () :void
    {
        if (_wctx == null) {
            log.error("Aii Leaving the world with no configured world context.");
            // but let it happen
        }
        _wctx == null;
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



    protected const _client :AetherClient = inject(AetherClient);

    protected var _wctx :WorldContext;

    protected static const log :Log = Log.getLog(OrthContext);
}
}
