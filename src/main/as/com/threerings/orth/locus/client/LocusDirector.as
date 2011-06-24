//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.locus.client {
import flash.display.Sprite;
import com.threerings.orth.locus.data.HostedLocus;
import flash.utils.getQualifiedClassName;

import flashx.funk.ioc.inject;

import com.threerings.util.ClassUtil;
import com.threerings.util.Log;
import com.threerings.util.Map;
import com.threerings.util.Maps;
import com.threerings.util.ObserverList;
import com.threerings.util.Preconditions;

import com.threerings.presents.client.BasicDirector;
import com.threerings.presents.client.Client;
import com.threerings.presents.client.ClientAdapter;
import com.threerings.presents.client.ClientEvent;
import com.threerings.presents.client.ClientObserver;

import com.threerings.orth.client.OrthContext;
import com.threerings.orth.client.TopPanel;
import com.threerings.orth.data.OrthCodes;
import com.threerings.orth.locus.data.Locus;
import com.threerings.orth.locus.data.LocusMarshaller;
import com.threerings.orth.nodelet.data.HostedNodelet;

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

        _observer = new ClientAdapter(null, locusLogon, null, null, locusFail, locusFail);
    }

    /**
     * The locus we most recently moved into. The {@link Locus} superclass itself contains no
     * interesting information; specific subclass inspection is needed to find out details.
     *
     * This value may be null, if we've yet to log in, disconnected, or we are in mid-move.
     */
    public function get currentLocus () :Locus
    {
        return _current;
    }

    /**
     * The currently active {@link LocusContext}.
     *
     * This value may be null, if we've yet to log in, disconnected, or we are in mid-move.
     */
    public function get currentContext () :LocusContext
    {
        return _currentCtx;
    }

    /**
     * The hostname of the locus peer we're currently logged into.
     *
     * This value may be null, if we've yet to log in, disconnected, or we are in mid-move.
     */
    public function get currentPeer () :String
    {
        return _currentPeer;
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
    public function moveTo (locus :Locus) :void
    {
        if (_pending != null) {
            // this might be a bit too hard-ass, but they *can* always restart their client...
            log.warning("Refusing to move while we're already in mid-move",
                "desired", locus, "pending", _pending);
            return;
        }

        // remember where we're going
        _pending = locus;

        // Clear the current view out since it's no longer active.
        // TODO - add a spinner for when locus materialization takes a while
        _top.setMainView(new Sprite());

        // begin by locating the correct peer
        _lsvc.materializeLocus(_pending, this);

        _locusObservers.apply(function (obs :Object) :void {
            LocusObserver(obs).locusWillChange(locus);
        });
    }

    // from Java LocusService_PlaceResolutionListener
    public function requestFailed (cause :String) :void
    {
        _locusObservers.apply(function (obs :Object) :void {
            LocusObserver(obs).locusChangeFailed(_pending, cause);
        });

        // clear our pending move
        _pending = null;

        log.warning("Place resolution request failed", "cause", cause);
        _octx.displayFeedback(OrthCodes.WORLD_MSGS, cause);
    }

    // from Java LocusService_PlaceResolutionListener
    public function locusMaterialized (hosted :HostedLocus) :void
    {
        // note our peer
        _pendingPeer = hosted.host;

        // look up the destination context (aka fail early)
        var pendingCtx :LocusContext = _contexts.get(getQualifiedClassName(_pending));
        if (pendingCtx == null) {
            throw new Error("Aii! Unknown Locus type: " + getQualifiedClassName(_pending));
        }

        var locusClient :LocusClient;

        // is this the very special case where we're already on the right peer?
        if (_currentCtx != null && ClassUtil.isSameClass(_pending, _current) &&
            _currentCtx.getClient().isConnected() && _pendingPeer == _currentPeer) {
            gotoPendingPlace();
            return;
        }

        // if not we probably need to log out
        if (_currentCtx != null) {
            locusClient = _currentCtx.getLocusClient();
            // first stop listening to the client
            locusClient.removeClientObserver(_observer);
            _clientObservers.apply(locusClient.removeClientObserver);

            // the really cut the cord
            locusClient.logoff(false);
        }

        // now grab the (possibly) new client
        locusClient = pendingCtx.getLocusClient();

        // listen to it
        locusClient.addClientObserver(_observer);
        _clientObservers.apply(locusClient.addClientObserver);

        // switch to the new context
        _currentCtx = pendingCtx;

        // and finally log on
        locusClient.logonTo(_pendingPeer, hosted.ports);
    }

    // called if our connection to the locus server fails or we fail to login
    public function locusFail (event :ClientEvent) :void
    {
        log.warning("Locus connection failed", "place", _current, "event", event);

        _locusObservers.apply(function (obs :Object) :void {
            LocusObserver(obs).locusChangeFailed(_pending, "Locus connection failed");;
        });

        _octx.displayFeedback(OrthCodes.WORLD_MSGS, "Connection failed");
    }

    protected function locusLogon (event :ClientEvent) :void
    {
        _currentPeer = _pendingPeer;
        gotoPendingPlace();
    }

    protected function gotoPendingPlace () :void
    {
        Preconditions.checkNotNull(_currentCtx,
            "We logged onto a locus server but the locus context is gone!");

        // we successfully logged on; hand control over to the locus implementation
        _current = _pending;

        // squirrel this away before we reset our class members
        var locus :Locus = _pending;

        _pendingPeer = null;
        _pending = null;

        // finally go!
        _currentCtx.go(locus);

        _locusObservers.apply(function (obs :Object) :void {
            LocusObserver(obs).locusDidChange(locus);
        });
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

    protected var _currentCtx :LocusContext;

    protected var _octx :OrthContext = inject(OrthContext);
    protected var _top :TopPanel = inject(TopPanel);

    protected var _lsvc :LocusService;

    protected var _contexts :Map = Maps.newMapOf(Class);

    protected var _clientObservers :ObserverList =
        new ObserverList(ObserverList.SAFE_IN_ORDER_NOTIFY);

    protected var _locusObservers :ObserverList =
        new ObserverList(ObserverList.SAFE_IN_ORDER_NOTIFY);

    protected var _observer :ClientObserver;

    protected var _current :Locus;
    protected var _currentPeer :String;

    protected var _pending :Locus;
    protected var _pendingPeer :String;
}
}
