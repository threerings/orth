//
// Who - Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.instance.data;

import java.util.List;
import java.util.Map;

import com.google.common.base.Preconditions;
import com.google.common.collect.Lists;
import com.google.common.collect.Maps;
import com.google.inject.Inject;

import com.samskivert.util.Invoker;
import com.samskivert.util.ObserverList;

import com.samskivert.jdbc.RepositoryUnit;

import com.threerings.presents.annotation.MainInvoker;
import com.threerings.presents.client.InvocationService.ConfirmListener;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.server.InvocationException;

import com.threerings.crowd.data.BodyObject;
import com.threerings.crowd.server.BodyLocator;
import com.threerings.crowd.server.PlaceManager;
import com.threerings.crowd.server.PlaceRegistry;

import com.threerings.whirled.Log;
import com.threerings.whirled.data.Scene;
import com.threerings.whirled.data.SceneModel;
import com.threerings.whirled.data.ScenePlace;
import com.threerings.whirled.server.SceneManager;
import com.threerings.whirled.server.SceneRegistry.ConfigFactory;
import com.threerings.whirled.server.SceneRegistry.ResolutionListener;
import com.threerings.whirled.server.SceneRegistry;
import com.threerings.whirled.server.persist.SceneRepository;
import com.threerings.whirled.spot.client.SpotService;
import com.threerings.whirled.spot.data.Location;
import com.threerings.whirled.spot.data.SpotCodes;
import com.threerings.whirled.util.NoSuchSceneException;
import com.threerings.whirled.util.SceneFactory;
import com.threerings.whirled.util.UpdateList;

import com.threerings.orth.instance.server.InstanceLocal;
import com.threerings.orth.instance.server.InstanceRegistry;
import com.threerings.orth.instance.server.InstancedSceneManager;

import static com.threerings.whirled.spot.Log.log;

public class Instance
{
    /**
     * Return the given {@link BodyObject}'s Instance, or null if none.
     */
    public static Instance getFor (BodyObject body)
    {
        InstanceLocal local = body.getLocal(InstanceLocal.class);
        return (local != null) ? local.instance : null;
    }

    /**
     * Return the given {@link BodyObject}'s Instance, throwing if there is none.
     */
    public static Instance requireFor (BodyObject body)
    {
        return Preconditions.checkNotNull(getFor(body),
            "Body of %s is not in an instance", body.username);
    }

    /**
     * To be implemented by parties interested in instance changes.
     */
    public interface InstanceObserver
    {
        /**
         * Notes that a player has been added to the instance.
         */
        public void playerAdded (Instance instance, BodyObject player);

        /**
         * Notes that a player has been removed from the instance.
         *
         * @param seconds the number of seconds spent in the instance.
         */
        public void playerRemoved (Instance instance, BodyObject player, int seconds);

        /**
         * Notes that the instance became empty of players and scenes.
         */
        public void instanceBecameEmpty (Instance instance);
    }

    public Instance (String instanceId)
    {
        _instanceId = instanceId;
    }

    public InstancedSceneManager getSceneManager (int sceneId)
    {
        return _scenemgrs.get(sceneId);
    }

    public String getInstanceId ()
    {
        return _instanceId;
    }

    /**
     * Return an {@link InstanceInfo} to represent this Instance. This method is meant to
     * be overridden by subclasses.
     */
    public InstanceInfo toInfo ()
    {
        return new InstanceInfo(_instanceId);
    }

    /**
     * Adds an observer to notify on player addition and removal.
     */
    public void addObserver (InstanceObserver observer)
    {
        _observers.add(observer);
    }

    /**
     * Removes an observer.
     */
    public void removeObserver (InstanceObserver observer)
    {
        _observers.remove(observer);
    }

    /**
     * Adds a player to this instance.
     */
    public void addPlayer (final BodyObject body)
    {
        InstanceLocal local = getLocal(body);
        if (local.instance != null) {
            local.instance.removePlayer(body);
        }
        local.instance = this;
        local.entered = System.currentTimeMillis();
        _population++;

        log.debug("Added player to instance", "player", body.username, "instance", _instanceId);

        if (body instanceof InstanceBody) {
            ((InstanceBody) body).addedTo(this);
        }

        // notify observers
        _observers.apply(new ObserverList.ObserverOp<InstanceObserver>() {
            public boolean apply (InstanceObserver observer) {
                observer.playerAdded(Instance.this, body);
                return true;
            }
        });
    }

    /**
     * Removes a player from this instance.
     */
    public void removePlayer (final BodyObject body)
    {
        if (getLocal(body).instance != this) {
            return;
        }
        InstanceLocal local = body.getLocal(InstanceLocal.class);
        local.instance = null;
        final int seconds = (int)((System.currentTimeMillis() - local.entered)/1000L);
        _population--;

        log.debug("Removed player from instance", "player", body.username, "instance", _instanceId);

        if (body instanceof InstanceBody) {
            ((InstanceBody) body).removedFrom(this);
        }

        // notify observers
        _observers.apply(new ObserverList.ObserverOp<InstanceObserver>() {
            public boolean apply (InstanceObserver observer) {
                observer.playerRemoved(Instance.this, body, seconds);
                return true;
            }
        });

        // check for emptiness
        checkEmpty();
    }

    /**
     * @see SpotService#changeLocation(int, Location, ConfirmListener)
     */
    public void changeLocation (ClientObject caller, int sceneId, Location loc,
        SpotService.ConfirmListener listener) throws InvocationException
    {
        BodyObject source = _locator.forClient(caller);
        int cSceneId = ScenePlace.getSceneId(source);
        if (cSceneId != sceneId) {
            log.info("Rejecting changeLocation for invalid scene",
                "user", source.who(), "insid", cSceneId, "wantsid", sceneId, "loc", loc);
            throw new InvocationException(SpotCodes.INVALID_LOCATION);
        }

        // look up the scene manager for the specified scene
        InstancedSceneManager smgr = getSceneManager(sceneId);
        if (smgr == null) {
            log.warning("User requested to change location from non-existent scene",
                "user", source.who(), "sceneId", sceneId, "loc", loc);
            throw new InvocationException(SpotCodes.INTERNAL_ERROR);
        }

        // pass the buck to yon scene manager
        smgr.handleChangeLoc(source, loc);

        // if that method finished, we're good to go
        listener.requestProcessed();
    }

    /**
     * Requests that the specified scene be resolved, which means loaded into the server and
     * initialized if the scene is not currently active. The supplied callback instance will be
     * notified, on the dobjmgr thread, when the scene has been resolved. If the scene is already
     * active, it will be notified immediately (before the call to {@link #resolveScene} returns).
     *
     * @param sceneId the id of the scene to resolve.
     * @param target a reference to a callback instance that will be notified when the scene has
     * been resolved (which may be immediately if the scene is already active).
     *
     * NOTE: Copied from SceneRegistry
     */
    public void resolveScene (int sceneId, ResolutionListener target)
    {
        SceneManager mgr = _scenemgrs.get(sceneId);
        if (mgr != null) {
            // the scene is already resolved, we're ready to roll
            target.sceneWasResolved(mgr);
            return;
        }

        // if the scene is already being resolved, we need do no more
        if (!addResolutionListener(sceneId, target)) {
            return;
        }

        // otherwise we have to load the scene from the repository
        final int fsceneId = sceneId;
        _invoker.postUnit(new RepositoryUnit("resolveScene(" + sceneId + ")") {
            @Override public void invokePersist () throws Exception {
                _model = _screp.loadSceneModel(fsceneId);
                _updates = _screp.loadUpdates(fsceneId);
                _extras = _screp.loadExtras(fsceneId, _model);
            }
            @Override public void handleSuccess () {
                processSuccessfulResolution(_model, _updates, _extras);
            }
            @Override public void handleFailure (Exception error) {
                processFailedResolution(fsceneId, error);
            }
            protected SceneModel _model;
            protected UpdateList _updates;
            protected Object _extras;
        });
    }

    /**
     * Called when the scene resolution has completed successfully.
     *
     * NOTE: Copied from SceneRegistry
     */
    protected void processSuccessfulResolution (
        SceneModel model, final UpdateList updates, final Object extras)
    {
        // now that the scene is loaded, we can create a scene manager for it. that will be
        // initialized by the place registry and when that is finally complete, then we can let our
        // penders know what's up

        try {
            // first create our scene instance
            final Scene scene = getSceneFactory().createScene(
                model, getConfigFactory().createPlaceConfig(model));

            // now create our scene manager
            _plreg.createPlace(scene.getPlaceConfig(), new PlaceRegistry.PreStartupHook() {
                public void invoke (PlaceManager pmgr) {
                    ((InstancedSceneManager)pmgr).setSceneData(
                        scene, updates, extras, Instance.this, getSceneRegistry());
                }
            });

            // when the scene manager completes its startup proceedings, it will call back to the
            // scene registry and let us know that we can turn the penders loose

        } catch (Exception e) {
            // so close, but no cigar
            processFailedResolution(model.sceneId, e);
        }
    }

    /**
     * Called if resolving the scene fails for some reason.
     *
     * NOTE: Copied from SceneRegistry
     */
    protected void processFailedResolution (int sceneId, Exception cause)
    {
        // if this is not simply a missing scene, log a warning
        if (!(cause instanceof NoSuchSceneException)) {
            log.info("Failed to resolve scene [sceneId=" + sceneId + "].", cause);
        }

        // alas things didn't work out, notify our penders
        List<ResolutionListener> penders = _penders.remove(sceneId);
        if (penders != null) {
            for (ResolutionListener rl : penders) {
                try {
                    rl.sceneFailedToResolve(sceneId, cause);
                } catch (Exception e) {
                    Log.log.warning("Resolution listener choked.", e);
                }
            }
            checkEmpty();
        }
    }

    /**
     * Called by the scene manager once it has started up (meaning that it has its
     * place object and is ready to roll).
     *
     * NOTE: Copied from SceneRegistry
     */
    public void sceneManagerDidStart (SceneManager scmgr)
    {
        // register this scene manager in our table
        int sceneId = scmgr.getScene().getId();
        _scenemgrs.put(sceneId, (InstancedSceneManager) scmgr);

        log.debug("Registering scene manager", "scid", sceneId, "scmgr", scmgr);

        // now notify any penders
        List<ResolutionListener> penders = _penders.remove(sceneId);
        if (penders != null) {
            for (ResolutionListener rl : penders) {
                try {
                    rl.sceneWasResolved(scmgr);
                } catch (Exception e) {
                    log.warning("Resolution listener choked.", e);
                }
            }
        }
    }

    /**
     * Called by the scene manager when it is shut down.
     *
     * NOTE: Copied from SceneRegistry
     */
    public void unmapSceneManager (SceneManager scmgr)
    {
        if (_scenemgrs.remove(scmgr.getScene().getId()) == null) {
            log.warning("Requested to unmap unmapped scene manager.", "scmgr", scmgr);
            return;
        }

        log.debug("Unmapped scene manager", "scmgr", scmgr);
        checkEmpty();
    }

    /**
     * Adds a callback for when the scene is resolved. Returns true if this is the first such
     * thing (and thusly, the caller should actually fire off scene resolution) or false if we've
     * already got a list and have just added this listener to it.
     *
     * NOTE: Copied from SceneRegistry
     */
    protected boolean addResolutionListener (int sceneId, ResolutionListener rl)
    {
        List<ResolutionListener> penders = _penders.get(sceneId);
        boolean newList = false;

        if (penders == null) {
            _penders.put(sceneId, penders = Lists.newArrayList());
            newList = true;
        }

        penders.add(rl);
        return newList;
    }

    /**
     * Checks for emptiness.
     */
    protected void checkEmpty ()
    {
        if (_scenemgrs.isEmpty() && _penders.isEmpty() && _population == 0) {
            _observers.apply(new ObserverList.ObserverOp<InstanceObserver>() {
                public boolean apply (InstanceObserver observer) {
                    observer.instanceBecameEmpty(Instance.this);
                    return true;
                }
            });
        }
    }

    // subclasses could use a different SceneFactory
    protected SceneFactory getSceneFactory ()
    {
        return _defscfact;
    }

    // subclasses could use a different ConfigFactory
    protected ConfigFactory getConfigFactory ()
    {
        return _defconfact;
    }

    // subclasses could use a different SceneRegistry
    protected SceneRegistry getSceneRegistry ()
    {
        return _defscreg;
    }

    protected InstanceLocal getLocal (BodyObject body)
    {
        InstanceLocal local = body.getLocal(InstanceLocal.class);
        if (local == null) {
            local = new InstanceLocal();
            body.setLocal(InstanceLocal.class, local);
        }
        return local;
    }

    protected String _instanceId;
    protected int _population;
    protected ObserverList<InstanceObserver> _observers = ObserverList.newFastUnsafe();

    /** A mapping from scene ids to scene managers. */
    protected Map<Integer, InstancedSceneManager> _scenemgrs = Maps.newHashMap();

    /** The table of pending resolution listeners. */
    protected Map<Integer, List<ResolutionListener>> _penders = Maps.newHashMap();

    @Inject protected @MainInvoker Invoker _invoker;
    @Inject protected BodyLocator _locator;
    @Inject protected ConfigFactory _defconfact;
    @Inject protected InstanceRegistry _instreg;
    @Inject protected PlaceRegistry _plreg;
    @Inject protected SceneFactory _defscfact;
    @Inject protected SceneRegistry _defscreg;
    @Inject protected SceneRepository _screp;
}
