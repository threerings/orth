//
// Who - Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.instance.server;

import com.google.inject.Inject;

import com.threerings.presents.server.InvocationException;

import com.threerings.crowd.data.BodyObject;

import com.threerings.whirled.data.Scene;
import com.threerings.whirled.server.SceneManager;
import com.threerings.whirled.server.SceneRegistry;
import com.threerings.whirled.spot.data.Location;
import com.threerings.whirled.spot.server.SpotSceneManager;
import com.threerings.whirled.util.UpdateList;

import com.threerings.orth.data.AuthName;
import com.threerings.orth.data.Whereabouts;
import com.threerings.orth.instance.data.Instance;
import com.threerings.orth.peer.server.OrthPeerManager;

public abstract class InstancedSceneManager extends SpotSceneManager
{
    /**
     * Return the instance of this scene we're managing, or null.
     */
    public Instance getInstance ()
    {
        return _instance;
    }

    /**
     * When we're representing an instanced scene, it's this method that's called, rather
     * than {@link SceneManager#setSceneData(Scene, UpdateList, Object, SceneRegistry)}.
     */
    public void setSceneData (Scene scene, UpdateList updates, Object extras,
        Instance instance, SceneRegistry screg)
    {
        super.setSceneData(scene, updates, extras, screg);
        _instance = instance;

        _whereabouts = createWhereabouts();

    }

    // only overridden to widen to public
    @Override public void handleChangeLoc (BodyObject source, Location loc)
        throws InvocationException
    {
        super.handleChangeLoc(source, loc);
    }

    @Override // from PlaceManager
    public void bodyWillEnter (BodyObject body)
    {
        super.bodyWillEnter(body);

        if (_whereabouts != null && body.username instanceof AuthName) {
            // notify peers of our arrival in a locus
            _peerMgr.updateWhereabouts((AuthName) body.username, _whereabouts);
        }
    }

    @Override // from PlaceManager
    public void bodyWillLeave (BodyObject body)
    {
        super.bodyWillLeave(body);

        if (_whereabouts != null && body.username instanceof AuthName) {
            // notify peers of our departure from this locus
            _peerMgr.updateWhereabouts((AuthName) body.username);
        }
    }

    @Override protected void didShutdown ()
    {
        super.didShutdown();

        deregisterPlace();
    }

    /**
     * If any global or peered registration took place as part of creating this place,
     * this method, which is called on shutdown, may be used to clear said registration out.
     */
    abstract protected void deregisterPlace ();

    abstract protected Whereabouts createWhereabouts ();

    /** The instance this place is in. */
    protected Instance _instance;

    /** The whereabouts of anybody in this room. */
    protected Whereabouts _whereabouts;

    @Inject protected OrthPeerManager _peerMgr;
}
