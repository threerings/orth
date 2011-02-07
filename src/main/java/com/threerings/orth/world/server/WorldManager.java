//
// $Id: $

package com.threerings.orth.world.server;

import java.util.Map;

import com.google.common.collect.Maps;
import com.google.inject.Inject;

import com.samskivert.util.ResultListener;

import com.threerings.io.SimpleStreamableObject;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.peer.data.NodeObject;
import com.threerings.presents.peer.server.PeerManager;
import com.threerings.presents.server.InvocationException;

import com.threerings.crowd.data.PlaceConfig;
import com.threerings.crowd.server.LocationManager;

import com.threerings.whirled.data.SceneModel;
import com.threerings.whirled.server.SceneManager;
import com.threerings.whirled.server.SceneRegistry;
import com.threerings.whirled.server.SceneRegistry.ResolutionListener;

import com.threerings.orth.aether.data.PlayerObject;
import com.threerings.orth.peer.server.OrthPeerManager;
import com.threerings.orth.world.client.WorldService.PlaceResolutionListener;
import com.threerings.orth.world.data.OrthPlace;
import com.threerings.orth.world.data.PlaceKey;

import static com.threerings.orth.Log.log;

/**
 * Accept a move request from the client and figure out what to do with it.
 */
public class WorldManager
    implements WorldProvider
{
    /**
     * Implemented by server-side systems that want to build Orth places.
     */
    public interface PlaceFactory
    {
        public void resolve (PlaceKey key, PlaceResolutionListener listener);
    }

    /**
     * Locate, possibly hosting, the given Orth place, and tell the client where to find it. 
     */
    public void locatePlace (
        ClientObject caller, final PlaceKey key, final PlaceResolutionListener listener)
        throws InvocationException
    {
        // ORTH TODO: Sanity check caller, throttle requests?

        OrthPlace place = _peerMgr.findHostedPlace(key);
        // if it's already hosted, great
        if (place != null) {
            listener.placeLocated(place);
            return;
        }

        // ORTH TODO: At this point we know the place needs to be hosted. For now, we will
        // resolve it locally, but what should really happen here is that the nodes should
        // all be queried to see which world peer is the least loaded and the request should
        // be punted to there. For now, we simply assume that all peers are both aether and
        // world peers, and thus attempt to resolve the place locally.

        final NodeObject.Lock lock = OrthPeerManager.getPlaceLock(key);
        _peerMgr.acquireLock(lock, new ResultListener<String>() {
            public void requestCompleted (String nodeName) {
                if (_peerMgr.getNodeObject().nodeName.equals(nodeName)) {
                    log.info("Got lock, resolving place", "place", key);
                    try {
                        PlaceFactory factory = _factories.get(key.getPlaceType());
                        if (factory == null) {
                            throw new IllegalStateException("Can't resolve unknown place type!");
                        }
                        factory.resolve(key, listener);

                        // ORTH TODO: We have to actually update HostedPlaces

                    } finally {
                        _peerMgr.releaseLock(lock, new ResultListener.NOOP<String>());
                    }

                } else {
                    // we didn't get the lock, so let's see what happened by re-checking
                    OrthPlace place = _peerMgr.findHostedPlace(key);
                    if (place == null || nodeName == null || !nodeName.equals(place.getPeer())) {
                        log.warning("Place resolved on wacked-out node?",
                            "key", key, "nodeName", nodeName, "place", place);
                        listener.resolutionFailed(key, "Whacked Out Node");

                    } else {
                        // someone sniped us, return a reference to their newly hosted place
                        listener.placeLocated(place);
                    }
                }
            }
            public void requestFailed (Exception cause) {
                log.warning("Failed to acquire place resolution lock", "place", key, cause);
                listener.resolutionFailed(key, cause.getMessage());
            }
        });        
    }

    protected Map<String, PlaceFactory> _factories = Maps.newHashMap();

    @Inject protected OrthPeerManager _peerMgr;
}
