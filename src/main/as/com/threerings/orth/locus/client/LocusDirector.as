package com.threerings.orth.locus.client {
import flash.utils.getQualifiedClassName;

import flashx.funk.ioc.inject;

import com.threerings.util.Log;
import com.threerings.util.ObserverList;
import com.threerings.util.Preconditions;

import com.threerings.presents.client.BasicDirector;
import com.threerings.presents.client.Client;
import com.threerings.presents.client.ClientAdapter;
import com.threerings.presents.client.ClientEvent;
import com.threerings.presents.client.ClientObserver;

import com.threerings.orth.client.OrthContext;
import com.threerings.orth.data.OrthCodes;
import com.threerings.orth.locus.client.LocusService;
import com.threerings.orth.locus.client.LocusService_LocusMaterializationListener;
import com.threerings.orth.locus.data.Locus;
import com.threerings.orth.locus.data.LocusMarshaller;
import com.threerings.orth.nodelet.data.HostedNodelet;

/**
 * Handles moving around in the virtual locus.
 *
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
    public function locusMaterialized (hosted :HostedNodelet) :void
    {
        // note our peer
        _pendingPeer = hosted.host;

        var locusClient :LocusClient = (_octx.wctx != null) ? _octx.wctx.getLocusClient() : null;

        // if we're switching place types, we need to instantiate a new locus system
        if (locusClient == null || _current == null ||
            getQualifiedClassName(_pending) != getQualifiedClassName(_current)) {
            _octx.setupLocus(_pending.moduleClass);

        } else if (locusClient.isConnected() && _pendingPeer == _currentPeer) {
            // this is the special case where we're already on the right peer
            gotoPendingPlace();
            return;
        }

        // otherwise, we need to log out
        if (locusClient != null) {
            // first stop listening to the client
            locusClient.removeClientObserver(_observer);
            _clientObservers.apply(locusClient.removeClientObserver);

            // the really cut the cord
            locusClient.logoff(false);
        }

        // make sure we're manipulating the right client henceforth
        locusClient = _octx.wctx.getLocusClient();

        // listen to it
        locusClient.addClientObserver(_observer);
        _clientObservers.apply(locusClient.addClientObserver);

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
        Preconditions.checkNotNull(_octx.wctx,
            "We logged onto a locus server but the locus context is gone!");

        // we successfully logged on; hand control over to the locus implementation
        _current = _pending;

        // squirrel this away before we reset our class members
        var locus :Locus = _pending;

        _pendingPeer = null;
        _pending = null;

        // finally go!
        _octx.wctx.go(locus);

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

    protected var _octx :OrthContext = inject(OrthContext);

    protected var _lsvc :LocusService;

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
