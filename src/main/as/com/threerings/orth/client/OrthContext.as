//
// $Id$

package com.threerings.orth.client {
import flashx.funk.ioc.inject;

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
import com.threerings.presents.util.PresentsContext;

import com.threerings.orth.aether.client.AetherClient;
import com.threerings.orth.aether.data.PlayerName;
import com.threerings.orth.aether.data.PlayerObject;
import com.threerings.orth.chat.client.OrthChatDirector;
import com.threerings.orth.data.OrthCodes;
import com.threerings.orth.locus.client.AbstractLocusModule;
import com.threerings.orth.locus.client.LocusContext;
import com.threerings.orth.locus.client.LocusModule;
import com.threerings.orth.notify.client.NotificationDirector;

/**
 * This is the beating heart of an Orth-based client. It provides access to the Aether client
 * and its associated distributed object manager along with all the directors responsible for
 * the services that take place over the Aether link.
 *
 * Whenever the player is in a locus location, this context additionally returns a non-null
 * reference to a {@link LocusContext}, which is the nexus of the entirely distinct other half
 * of the client's workings: a separate client connected to its own server and distributed object
 * system and, consequently, a different set of directors to take advantage of it all.
 *
 * Never confuse the two contexts. They represent different systems. This one is primary, in that
 * there is always an {@link OrthContext} and always an {@link AetherClient}, but only some of
 * the time is that true for {@link LocusContext} and {@link LocusClient}.
 */
public class OrthContext
    implements PresentsContext
{
    public function OrthContext ()
    {
        // initialize our convenience holder
        Msgs.init(inject(MessageManager));
    }

    // called from OrthModule once this context and all its dependents are safely constructed
    public function didInit () :void
    {
        // The notification director is an abstract class but generally should be bound to
        // something. We can't create it in the constructor because it needs a context.
        // TODO: In general, a Context creates directors and directors inject a context so hmm...
        //       Maybe a createDirectors method here like in msoy? Zell, you have a plan?
        // TODO: make the notification director a little more usable...
        //       it shouldn't need to be abstract
        try {
            inject(NotificationDirector);
        } catch (e :Error) {
            log.info("No notification director injected, proceeding");
        }
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
     * Return a reference to the current {@link LocusContext}, or null if the player is
     * not currently in a location.
     */
    public function get wctx () :LocusContext
    {
        return _wctx;
    }

    /**
     * Instantiate a new {@link AbstractLocusModule} and use it to fire up a {@link LocusContext}
     * of the correct concrete subtype, which in turn will instantiate all the necessary
     * infrastructure.
     */
    public function setupLocus (moduleClass :Class) :void
    {
        // instantiate the correct LocusModule subclass
        var wMod :AbstractLocusModule = new moduleClass();

        var cMod :LocusModule = wMod.init(_module);

        // and finally use it to bring the correct LocusContext subclass to life
        log.info("Initializing new LocusContext", "mod", cMod);
        _wctx = cMod.getInstance(LocusContext);
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

    public function getMyId () :int
    {
        var player :PlayerObject = getPlayerObject();
        return (player != null) ? player.playerName.getId() : 0;
    }

    // from OrthContext
    public function listener (bundle :String = OrthCodes.GENERAL_MSGS,
        errWrap :String = null, ... logArgs) :InvocationService_InvocationListener
    {
        return new InvocationAdapter(chatErrHandler(bundle, errWrap, logArgs));
    }

    // from OrthContext
    public function confirmListener (bundle :String = OrthCodes.GENERAL_MSGS, confirm :* = null,
        errWrap :String = null, ... logArgs)
        :InvocationService_ConfirmListener
    {
        var success :Function = function () :void {
            if (confirm is Function) {
                (confirm as Function)();
            } else if (confirm is String) {
                displayFeedback(bundle, String(confirm));
            }
        };
        return new ConfirmAdapter(success, chatErrHandler(bundle, errWrap, logArgs));
    }

    // from OrthContext
    public function resultListener (gotResult :Function, bundle :String = OrthCodes.GENERAL_MSGS,
        errWrap :String = null, ... logArgs)
        :InvocationService_ResultListener
    {
        return new ResultAdapter(gotResult, chatErrHandler(bundle, errWrap, logArgs));
    }

    // from OrthContext
    public function displayFeedback (bundle :String, message :String) :void
    {
        _module.getInstance(OrthChatDirector).displayFeedback(bundle, message);
    }

    /**
     * Create an error handling function for use with InvocationService listener adapters.
     */
    public function chatErrHandler (bundle :String, errWrap :String, logArgs :Array) :Function
    {
        return function (cause :String) :void {
            var args :Array = logArgs.concat("cause", cause); // make a copy, we're reentrant
            if (args.length % 2 == 0) {
                args.unshift("Reporting failure");
            }
            log.info.apply(null, args);

            if (errWrap != null) {
                cause = MessageBundle.compose(errWrap, cause);
            }
            displayFeedback(bundle, cause);
        };
    }

    protected const _client :AetherClient = inject(AetherClient);
    protected const _module :OrthModule = inject(OrthModule);

    protected var _wctx :LocusContext;

    protected static const log :Log = Log.getLog(OrthContext);
}
}
