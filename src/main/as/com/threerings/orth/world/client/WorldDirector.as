//
// $Id: WorldDirector.as 18771 2009-11-24 22:03:46Z jamie $

package com.threerings.orth.world.client {
import flashx.funk.ioc.inject;

import com.threerings.io.TypedArray;

import com.threerings.util.Log;

import com.threerings.presents.client.BasicDirector;
import com.threerings.presents.client.Client;
import com.threerings.presents.client.ClientAdapter;
import com.threerings.presents.client.ClientEvent;
import com.threerings.presents.client.ClientObserver;

import com.threerings.orth.client.OrthContext;
import com.threerings.orth.data.OrthCodes;
import com.threerings.orth.world.data.PlaceKey;
import com.threerings.orth.world.data.WorldMarshaller;

/**
 * Handles moving around in the virtual world.
 *
 */
public class WorldDirector extends BasicDirector
    implements WorldService_PlaceResolutionListener
{
    public const log :Log = Log.getLog(this);

    // statically reference classes we require
    WorldMarshaller;

    public function WorldDirector ()
    {
        super(_octx);

        _observer = new ClientAdapter(null, worldLogon, null, null, worldFail, worldFail);
    }

    /**
     * Request a move.
     */
    public function moveTo (place :PlaceKey) :void
    {
        if (_pendingPlace != null) {
            // this might be a bit too hard-ass, but they *can* always restart their client...
            log.warning("Refusing to move while we're already in mid-move",
                "desired destination", place, "pending destination", _pendingPlace);
            return;
        }

        // remember where we're going
        _pendingPlace = place;

        // begin by locating the correct peer
        _wsvc.locatePlace(place, this);
    }

    // from Java WorldService_PlaceResolutionListener
    public function requestFailed (cause :String) :void
    {
        // clear our pending move
        _pendingPlace = null;

        log.warning("Place resolution request failed", "cause", cause);
        _octx.displayFeedback(OrthCodes.WORLD_MSGS, cause);
    }

    // from Java WorldService_PlaceResolutionListener
    public function placeLocated (peer :String, host :String, ports :TypedArray) :void
    {
        // note our peer
        _pendingPeer = peer;

        var worldClient :WorldClient = (_octx.wctx != null) ? _octx.wctx.getWorldClient() : null;

        // if we're switching place types, we need to instantiate a new world system
        if (_currentPlace == null ||
            _pendingPlace.getPlaceType() != _currentPlace.getPlaceType()) {
            _octx.setupWorld(_pendingPlace.getModuleClass());

        } else if (worldClient.isConnected() && peer == _currentPeer) {
            // this is the special case where we're already on the right peer
            gotoPendingPlace();
            return;
        }

        // otherwise, we need to log out
        if (worldClient != null) {
            // first stop listening to the client
            worldClient.removeClientObserver(_observer);

            // the really cut the cord
            worldClient.logoff(false);
        }

        // make sure we're manipulating the right client henceforth
        worldClient = _octx.wctx.getWorldClient();

        // listen to it
        worldClient.addClientObserver(_observer);

        // and finally log on
        worldClient.logonTo(host, ports);
    }

    // called if our connection to the world server fails or we fail to login
    public function worldFail (event :ClientEvent) :void
    {
        log.warning("World connection failed", "place", _currentPlace, "event", event);
        _octx.displayFeedback(OrthCodes.WORLD_MSGS, "Connection failed");
    }

    protected function worldLogon (event :ClientEvent) :void
    {
        _currentPeer = _pendingPeer;
        gotoPendingPlace();
    }

    protected function gotoPendingPlace () :void
    {
        if (_octx.wctx == null) {
            log.warning("Freak out! We logged onto a world server but the world context is gone!");
            return;
        }

        // we successfully logged on; hand control over to the world implementation
        _currentPlace = _pendingPlace;

        _pendingPeer = null;
        _pendingPlace = null;

        _octx.wctx.gotoPlace(_currentPlace);
    }

    // from BasicDirector
    override protected function registerServices (client :Client) :void
    {
        client.addServiceGroup(OrthCodes.WORLD_GROUP);
    }

    // from BasicDirector
    override protected function fetchServices (client :Client) :void
    {
        super.fetchServices(client);

        _wsvc = (client.requireService(WorldService) as WorldService);
    }

    protected var _octx :OrthContext = inject(OrthContext);

    protected var _wsvc :WorldService;

    protected var _observer :ClientObserver;

    protected var _currentPlace :PlaceKey;
    protected var _currentPeer :String;

    protected var _pendingPlace :PlaceKey;
    protected var _pendingPeer :String;
}
}
