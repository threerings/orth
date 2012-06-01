//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.locus.client {

import flash.utils.getQualifiedClassName;

import flashx.funk.ioc.inject;

import org.osflash.signals.Signal;

import com.threerings.util.ClassUtil;
import com.threerings.util.DelayUtil;
import com.threerings.util.F;
import com.threerings.util.Log;
import com.threerings.util.Map;
import com.threerings.util.Maps;
import com.threerings.util.ObserverList;

import com.threerings.presents.client.BasicDirector;
import com.threerings.presents.client.Client;
import com.threerings.presents.client.ClientAdapter;
import com.threerings.presents.client.ClientEvent;
import com.threerings.presents.client.ClientObserver;

import com.threerings.orth.client.Listeners;
import com.threerings.orth.client.OrthContext;
import com.threerings.orth.data.OrthCodes;
import com.threerings.orth.locus.data.HostedLocus;
import com.threerings.orth.locus.data.Locus;
import com.threerings.orth.locus.data.LocusMarshaller;

/**
 * Handles moving around between loci.
 *
 * TODO: It's only halfway useful to have an observation mechanism that reports only at the
 * point of materialization, not when the movement actually completes. Suggest we add a callback
 * to LocusContext.go().
 */
public class LocusDirector extends BasicDirector
    implements LocusService_LocusMaterializationListener
{
    // statically reference classes we require
    LocusMarshaller;

    /**
     * Called when we've initiated a locus change.
     */
    public const locusWillChange :Signal = new Signal(Locus);

    /**
     * Called when the vault server returns our materialization request, but before we
     * initiate the connection/login to the new host.
     */
    public const locusDidMaterialize :Signal = new Signal(HostedLocus);

    /**
     * Called when we have switched to a new locus. Note: this only means we've connected
     * to the locus server and {@link LocusContext#go} has been called. Beyond that, there is
     * typically an implementation-specific process by which the player actually ends up in a
     * place.
     *
     * An alternate observation approach might be through {@OrthPlaceBox}.
     */
    public const locusDidChange :Signal = new Signal(HostedLocus);

    /**
     * This is called locus change request is rejected by the server or fails for some other reason.
     */
    public const locusChangeFailed :Signal = new Signal(Locus, String);

    public function LocusDirector ()
    {
        super(_octx);

        _observer = new ClientAdapter(null, gotoConnecting, null, null, locusFail, locusFail);
    }

    /**
     * The locus we're in. The {@link Locus} superclass itself contains no
     * interesting information; specific subclass inspection is needed to find out details.
     *
     * This value may be null, if we've yet to log in, disconnected, or we are in mid-move.
     */
    public function get locus () :Locus
    {
        return _connected == null ? null : _connected.locus;
    }

    /**
     * The currently active {@link LocusContext}.
     *
     * This value may be null, if we've yet to log in, disconnected, or we are in mid-move.
     */
    public function get context () :LocusContext
    {
        return _connected == null ? null : getCtx(_connected);
    }

    /**
     * Our current connection
     *
     * This value may be null, if we've yet to log in, disconnected, or we are in mid-move.
     */
    public function get hostedLocus () :HostedLocus
    {
        return _connected;
    }

    override protected function clientObjectUpdated (client :Client) :void
    {
        super.clientObjectUpdated(client);

        if (_octx.aetherObject.locus != null) {
            DelayUtil.delayFrame(moveToLocus, [ _octx.aetherObject.locus ]);
        }
    }

    /**
     * Inform Orth that a {@link Locus} of the given concrete class shall be initialized
     * through the provided {@link AbstractLocusModule} class.
     */
    public function addBinding (locusClass :Class, moduleClass :Class) :void
    {
        log.info("Instantiating Locus subsystem", "moduleClass", moduleClass);
        var ctx :LocusContext = _octx.setupLocus(moduleClass);

        _contexts.put(getQualifiedClassName(locusClass), ctx);
    }

    public function addLocusClientObserver (observer :ClientObserver) :void
    {
        _clientObservers.add(observer);
    }

    public function removeLocusClientObserver (observer :ClientObserver) :void
    {
        _clientObservers.remove(observer);
    }

    /**
     * Request a move.
     */
    public function moveToLocus (dest :Locus) :void
    {
        var self :LocusDirector = this;
        performMove(dest, (dest != null) ? reallyMove : justLeave);

        function reallyMove () :void {
            _materializing = dest;
            _lsvc.materializeLocus(_materializing, self)
        }

        function justLeave () :void {
            logout();
            // just in case, so this can be used to get back from a screwed state
            _connecting = null;
            _materializing = null;

            locusDidChange.dispatch(null);
        }
    }

    public function moveToHostedLocus (dest :HostedLocus) :void
    {
        performMove(dest.locus, F.callback(locusMaterialized, dest));
    }

    protected function performMove (dest :Locus, mover :Function) :void
    {
        if (_materializing != null || _connecting != null) {
            // this might be a bit too hard-ass, but they *can* always restart their client...
            log.warning("Refusing to move while we're already in mid-move",
                    "desired", dest, "materializing", _materializing, "connecting", _connecting);
            return;
        } else if (dest != null && !_contexts.containsKey(getQualifiedClassName(dest))) {
            log.warning("Aii! Unknown locus type",
                "dest", dest, "class", getQualifiedClassName(dest));
            return;
        } else if (dest != null && dest.equals(locus)) {
            log.warning("Already at dest?", "locus", locus, "dest", dest);
            return;
        }

        locusWillChange.dispatch(dest);

        mover();
    }

    // from Java LocusService_PlaceResolutionListener
    public function requestFailed (cause :String) :void
    {
        locusChangeFailed.dispatch(_materializing, cause);

        // clear our pending move
        _materializing = null;

        log.warning("Place resolution request failed", "cause", cause);
        Listeners.displayFeedback(OrthCodes.GENERAL_MSGS, cause);
    }

    // from Java LocusService_PlaceResolutionListener
    public function locusMaterialized (hosted :HostedLocus) :void
    {
        _connecting = hosted;
        _materializing = null;

        var ctx :LocusContext = getCtx(_connecting);
        if (ctx == null) {
            // this can happen if the server materializes a subclass of the original locus
            log.warning("Erk! Materialized unknown locus!", "locus", _connecting.locus);
            _connecting = null;
            return;
        }

        locusDidMaterialize.dispatch(hosted);

        // Are we already on the right peer in the right locus context?
        if (locus != null && ClassUtil.isSameClass(_connecting.locus, locus) &&
            _connecting.host == _connected.host) {
            gotoConnecting();
            return;
        }

        // if not, we must start by logging out
        if (_connected != null) {
            logout();
        }

        if (!ctx.prepareForConnection(_connecting, finished, failed)) {
            finished();
        }

        function finished () :void {

            // now grab the (possibly) new client
            const connectingClient :LocusClient = ctx.locusClient;

            // listen to it
            connectingClient.addClientObserver(_observer);
            _clientObservers.apply(connectingClient.addClientObserver);

            // and finally log on
            connectingClient.logonTo(_connecting.host, _connecting.ports);
        }

        function failed (error :String = null) :void {
            log.warning("Preparations for Locus connection failed", "locus", _connecting,
                "error", error);

            _connecting = null;
            _connected = null;
            Listeners.displayFeedback(OrthCodes.GENERAL_MSGS, "m.network_error");
        }
    }

    // called if our connection to the locus server fails or we fail to login
    public function locusFail (event :ClientEvent) :void
    {
        log.warning("Locus connection failed",
            "connected", _connected, "connecting", _connecting, "event", event);

        if (_connecting != null) {
            locusChangeFailed.dispatch(_connecting.locus, "Locus connection failed");
        }

        _connecting = null;
        _connected = null;
        Listeners.displayFeedback(OrthCodes.GENERAL_MSGS, "m.network_error");
    }

    protected function gotoConnecting (..._) :void
    {
        // we successfully logged on; hand control over to the locus implementation
        _connected = _connecting;
        _connecting = null;

        // finally go!
        context.go(locus);

        locusDidChange.dispatch(_connected);
    }

    protected function logout () :void
    {
        const connectedClient :LocusClient = this.context.locusClient;
        // first stop listening to the client
        connectedClient.removeClientObserver(_observer);
        _clientObservers.apply(connectedClient.removeClientObserver);
        _connected = null;

        // then really cut the cord
        connectedClient.logoff(false);
    }

    protected function getCtx (hosted :HostedLocus) :LocusContext
    {
        return _contexts.get(getQualifiedClassName(hosted.locus));
    }

    // from BasicDirector
    override protected function registerServices (client :Client) :void
    {
        client.addServiceGroup(OrthCodes.LOCUS_GROUP);
    }

    // from BasicDirector
    override protected function fetchServices (client :Client) :void
    {
        super.fetchServices(client);

        _lsvc = LocusService(client.requireService(LocusService));
    }


    protected const _octx :OrthContext = inject(OrthContext);

    protected var _lsvc :LocusService;

    protected const _contexts :Map = Maps.newMapOf(Class);

    protected const _clientObservers :ObserverList =
        new ObserverList(ObserverList.SAFE_IN_ORDER_NOTIFY);

    protected var _observer :ClientObserver;

    protected var _connected :HostedLocus;

    protected var _connecting :HostedLocus;

    protected var _materializing :Locus;

    private static const log :Log = Log.getLog(LocusDirector);
}
}
