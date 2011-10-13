//
// Who - Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.instance.server;

import com.google.inject.Inject;
import com.google.inject.Singleton;

import com.threerings.presents.client.InvocationService.ConfirmListener;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.server.InvocationException;
import com.threerings.presents.server.InvocationManager;

import com.threerings.crowd.data.BodyObject;

import com.threerings.whirled.client.SceneService.SceneMoveListener;
import com.threerings.whirled.server.SceneManager;
import com.threerings.whirled.server.SceneMoveHandler;
import com.threerings.whirled.spot.client.SpotService.SpotSceneMoveListener;
import com.threerings.whirled.spot.client.SpotService;
import com.threerings.whirled.spot.data.Location;
import com.threerings.whirled.spot.server.SpotSceneRegistry;

import com.threerings.orth.instance.data.Instance;

@Singleton
public class InstancingSceneRegistry extends SpotSceneRegistry
{
    /**
     * Constructs a instancing scene registry.
     */
    @Inject public InstancingSceneRegistry (InvocationManager invmgr)
    {
        super(invmgr);

        // deliberately sabotage SceneRegistry for fail-semi-fast sanity checking
        _scenemgrs = null;
        _penders = null;
    }

    @Override
    public void changeLocation (ClientObject caller, int sceneId, Location loc,
                                SpotService.ConfirmListener listener)
        throws InvocationException
    {
        Instance.requireFor(_locator.forClient(caller))
            .changeLocation(caller, sceneId, loc, listener);
    }

    @Override
    public void moveTo (ClientObject caller, int sceneId, int sceneVer, SceneMoveListener listener)
    {
        BodyObject body = _locator.forClient(caller);
        Instance.requireFor(body).resolveScene(
            sceneId, new SceneMoveHandler(_locman, body, sceneVer, listener));
    }

    @Override // documentation inherited
    protected void sceneManagerDidStart (SceneManager scmgr)
    {
        ((InstancedSceneManager)scmgr).getInstance().sceneManagerDidStart(scmgr);
    }

    @Override // documentation inherited
    protected void unmapSceneManager (SceneManager scmgr)
    {
        ((InstancedSceneManager)scmgr).getInstance().unmapSceneManager(scmgr);
    }

    // override from SceneRegistry
    @Override public void resolveScene (int sceneId, ResolutionListener target)
    {
        throw new RuntimeException("This method must not be called in instanced mode.");
    }

    // override from SpotSceneRegistry
    @Override
    public void traversePortal (ClientObject caller, int sceneId, int portalId,
        int destSceneVer, SpotSceneMoveListener listener)
        throws InvocationException
    {
        throw new RuntimeException("This method must not be called in instanced mode.");
    }

    // override from SpotSceneRegistry
    @Override public void joinCluster (ClientObject caller, int friendOid, ConfirmListener listener)
        throws InvocationException
    {
        throw new RuntimeException("This method must not be called in instanced mode.");
    }

    // override from SpotSceneRegistry
    @Override public void clusterSpeak (ClientObject caller, String message, byte mode)
    {
        throw new RuntimeException("This method must not be called in instanced mode.");
    }

    @Inject protected InstanceRegistry _instReg;
}
