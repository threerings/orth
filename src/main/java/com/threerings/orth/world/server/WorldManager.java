//
// $Id: $

package com.threerings.orth.world.server;

import java.util.Map;

import com.google.common.collect.Maps;
import com.google.inject.Inject;

import com.samskivert.util.ResultListener;
import com.samskivert.util.Tuple;

import com.threerings.presents.data.ClientObject;
import com.threerings.presents.peer.data.NodeObject;
import com.threerings.presents.server.InvocationException;

import com.threerings.orth.peer.data.HostedPlace;
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
        void resolvePlace (PlaceKey key, PlaceResolutionListener listener);

        OrthPlace toPlace (String nodeName, HostedPlace hostedPlace);

        String getHost ();

        int[] getPorts ();
    }

    /**
     * Locate, possibly hosting, the given Orth place, and tell the client where to find it.
     */
    public void locatePlace (
        ClientObject caller, final PlaceKey key, final PlaceResolutionListener listener)
        throws InvocationException
    {
        // ORTH TODO: Sanity check caller, throttle requests?
        Tuple<String, HostedPlace> hosting = _peerMgr.findHostedPlace(key);
        // if it's already hosted, great
        if (hosting != null) {
            placeLocated(listener, hosting.left, hosting.right);
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
                        getFactory(key).resolvePlace(key, listener);

                        // ORTH TODO: We have to actually update HostedPlaces

                    } finally {
                        _peerMgr.releaseLock(lock, new ResultListener.NOOP<String>());
                    }

                } else {
                    // we didn't get the lock, so let's see what happened by re-checking
                    Tuple<String, HostedPlace> hosting = _peerMgr.findHostedPlace(key);
                    if (hosting == null || nodeName == null || !nodeName.equals(hosting.left)) {
                        log.warning("Place resolved on wacked-out node?",
                            "key", key, "nodeName", nodeName, "hosting", hosting);
                        listener.requestFailed("Whacked Out Node");

                    } else {
                        // someone sniped us, return a reference to their newly hosted place
                        placeLocated(listener, hosting.left, hosting.right);
                    }
                }
            }
            public void requestFailed (Exception cause) {
                log.warning("Failed to acquire place resolution lock", "place", key, cause);
                listener.requestFailed(cause.getMessage());
            }
        });
    }

    private PlaceFactory getFactory (PlaceKey key)
    {
        final PlaceFactory factory = _factories.get(key.getPlaceType());
        if (factory == null) {
            throw new IllegalStateException("Can't resolve unknown place type!");
        }
        return factory;
    }

    protected void placeLocated (PlaceResolutionListener listener, String node, HostedPlace place)
    {
        PlaceFactory factory = getFactory(place.key);
        listener.placeLocated(factory.getHost(), factory.getPorts(), factory.toPlace(node, place));
    }

    protected Map<String, PlaceFactory> _factories = Maps.newHashMap();

    @Inject protected OrthPeerManager _peerMgr;
}
