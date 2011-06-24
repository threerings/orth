//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.locus.client {
import flash.display.Sprite;
import flash.utils.getQualifiedClassName;

import flashx.funk.ioc.inject;

import com.threerings.util.ClassUtil;
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

import com.threerings.orth.client.OrthContext;
import com.threerings.orth.client.TopPanel;
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
    public const log :Log = Log.getLog(this);

    // statically reference classes we require
    LocusMarshaller;

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

    /**
     * Inform Orth that a {@link Locus} of the given concrete class shall be initialized
     * through the provided {@link AbstractLocusModule} class.
     */
    public function addBinding (locusClass :Class, moduleClass :Class) :void
    {
        log.debug("Instantiating Locus subsystem", "moduleClass", moduleClass);
        var ctx :LocusContext = _octx.setupLocus(moduleClass);

        _contexts.put(getQualifiedClassName(locusClass), ctx);
    }

    public function addObserver (observer :LocusObserver) :void
    {
        _locusObservers.add(observer);
    }

    public function removeObserver (observer :LocusObserver) :void
    {
        _locusObservers.remove(observer);
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
        performMove(dest, function (..._) :void {
            _materializing = dest;
            _lsvc.materializeLocus(_materializing, self)
        });
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
        } else if (!_contexts.containsKey(getQualifiedClassName(dest))) {
            log.warning("Aii! Unknown locus type",
                "dest", dest, "class", getQualifiedClassName(dest));
            return;
        } else if (locus == dest) {
            log.warning("Already at dest?", "locus", locus, "dest", dest);
            return;
        }

        // Clear the current view out since it's no longer active.
        // TODO - add a spinner for when locus materialization takes a while
        _top.setMainView(new Sprite());

        mover();

        _locusObservers.apply(function (obs :LocusObserver) :void { obs.locusWillChange(dest); });
    }

    // from Java LocusService_PlaceResolutionListener
    public function requestFailed (cause :String) :void
    {
        _locusObservers.apply(function (obs :Object) :void {
            LocusObserver(obs).locusChangeFailed(_materializing, cause);
        });

        // clear our pending move
        _materializing = null;

        log.warning("Place resolution request failed", "cause", cause);
        _octx.displayFeedback(OrthCodes.WORLD_MSGS, cause);
    }

    // from Java LocusService_PlaceResolutionListener
    public function locusMaterialized (hosted :HostedLocus) :void
    {
        _connecting = hosted;
        _materializing = null;

        // Are we already on the right peer?
        if (locus != null && ClassUtil.isSameClass(_connecting.locus, locus) &&
            _connecting.host == _connected.host) {
            gotoConnecting();
            return;
        }

        // if not we probably need to log out
        if (_connected != null) {
            const connectedClient :LocusClient = context.getLocusClient();
            // first stop listening to the client
            connectedClient.removeClientObserver(_observer);
            _clientObservers.apply(connectedClient.removeClientObserver);
            _connected = null;

            // the really cut the cord
            connectedClient.logoff(false);
        }

        // now grab the (possibly) new client
        const connectingClient :LocusClient = getCtx(_connecting).getLocusClient();

        // listen to it
        connectingClient.addClientObserver(_observer);
        _clientObservers.apply(connectingClient.addClientObserver);

        // and finally log on
        connectingClient.logonTo(_connecting.host, _connecting.ports);
    }

    // called if our connection to the locus server fails or we fail to login
    public function locusFail (event :ClientEvent) :void
    {
        log.warning("Locus connection failed",
            "connected", _connected, "connecting", _connecting, "event", event);

        if (_connecting != null) {
            _locusObservers.apply(function (obs :Object) :void {
                LocusObserver(obs).locusChangeFailed(_connecting.locus, "Locus connection failed");
            });
        }

        _connecting = null;
        _connected = null;
        _octx.displayFeedback(OrthCodes.WORLD_MSGS, "Connection failed");
    }

    protected function gotoConnecting (..._) :void
    {
        // we successfully logged on; hand control over to the locus implementation
        _connected = _connecting;
        _connecting = null;

        // finally go!
        context.go(locus);

        _locusObservers.apply(function (obs :Object) :void {
            LocusObserver(obs).locusDidChange(locus);
        });
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
    protected const _top :TopPanel = inject(TopPanel);

    protected var _lsvc :LocusService;

    protected const _contexts :Map = Maps.newMapOf(Class);

    protected const _clientObservers :ObserverList =
        new ObserverList(ObserverList.SAFE_IN_ORDER_NOTIFY);

    protected const _locusObservers :ObserverList =
        new ObserverList(ObserverList.SAFE_IN_ORDER_NOTIFY);

    protected var _observer :ClientObserver;

    protected var _connected :HostedLocus;

    protected var _connecting :HostedLocus;

    protected var _materializing :Locus;
}
}
