package com.threerings.orth.world.client {
import flash.utils.getQualifiedClassName;

import flashx.funk.ioc.inject;

import com.threerings.util.Log;
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
import com.threerings.orth.locus.data.HostedLocus;
import com.threerings.orth.locus.data.Locus;
import com.threerings.orth.locus.data.LocusMarshaller;
import com.threerings.orth.room.data.HostedRoom;

/**
 * Handles moving around in the virtual world.
 *
 */
public class WorldDirector extends BasicDirector
    implements LocusService_LocusMaterializationListener
{
    public const log :Log = Log.getLog(this);

    // statically reference classes we require
    LocusMarshaller;
    HostedRoom;

    public function WorldDirector (externalObserver :ClientObserver = null)
    {
        super(_octx);

        _externalObserver = externalObserver;

        _observer = new ClientAdapter(null, worldLogon, null, null, worldFail, worldFail);
    }

    // TODO: Obviously this should be an addExternalObserver, TODO soon
    public function setExternalObserver (observer :ClientObserver) :void
    {
        _externalObserver = observer;
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
    }

    // from Java WorldService_PlaceResolutionListener
    public function requestFailed (cause :String) :void
    {
        // clear our pending move
        _pending = null;

        log.warning("Place resolution request failed", "cause", cause);
        _octx.displayFeedback(OrthCodes.WORLD_MSGS, cause);
    }

    // from Java WorldService_PlaceResolutionListener
    public function locusMaterialized (hosted :HostedLocus) :void
    {
        // note our peer
        _pendingPeer = hosted.host;

        var worldClient :WorldClient = (_octx.wctx != null) ? _octx.wctx.getWorldClient() : null;


        // if we're switching place types, we need to instantiate a new world system
        if (_current == null ||
            getQualifiedClassName(_pending) != getQualifiedClassName(_current)) {
            _octx.setupWorld(_pending.moduleClass);

        } else if (worldClient.isConnected() && _pendingPeer == _currentPeer) {
            // this is the special case where we're already on the right peer
            gotoPendingPlace();
            return;
        }

        // otherwise, we need to log out
        if (worldClient != null) {
            // first stop listening to the client
            worldClient.removeClientObserver(_observer);
            if (_externalObserver != null) {
                worldClient.removeClientObserver(_externalObserver);
            }

            // the really cut the cord
            worldClient.logoff(false);
        }

        // make sure we're manipulating the right client henceforth
        worldClient = _octx.wctx.getWorldClient();

        // listen to it
        worldClient.addClientObserver(_observer);
        if (_externalObserver != null) {
            worldClient.addClientObserver(_externalObserver);
        }

        // and finally log on
        worldClient.logonTo(_pendingPeer, hosted.ports);
    }

    // called if our connection to the world server fails or we fail to login
    public function worldFail (event :ClientEvent) :void
    {
        log.warning("World connection failed", "place", _current, "event", event);
        _octx.displayFeedback(OrthCodes.WORLD_MSGS, "Connection failed");
    }

    protected function worldLogon (event :ClientEvent) :void
    {
        _currentPeer = _pendingPeer;
        gotoPendingPlace();
    }

    protected function gotoPendingPlace () :void
    {
        Preconditions.checkNotNull(_octx.wctx,
            "We logged onto a world server but the world context is gone!");

        // we successfully logged on; hand control over to the world implementation
        _current = _pending;

        // squirrel this away before we reset our class members
        var locus :Locus = _pending;

        _pendingPeer = null;
        _pending = null;

        // finally go!
        _octx.wctx.go(locus);
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
    protected var _externalObserver :ClientObserver;

    protected var _observer :ClientObserver;

    protected var _current :Locus;
    protected var _currentPeer :String;

    protected var _pending :Locus;
    protected var _pendingPeer :String;
}
}
