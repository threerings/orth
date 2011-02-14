//
// $Id: $

package com.threerings.orth.server;

import com.google.inject.Inject;
import com.google.inject.Injector;
import com.google.inject.Singleton;

import com.threerings.presents.peer.server.PeerManager;

import com.threerings.crowd.server.CrowdServer;

import com.threerings.whirled.server.persist.SceneRepository;
import com.threerings.whirled.server.SceneRegistry;
import com.threerings.whirled.util.SceneFactory;

import com.threerings.orth.aether.server.AetherManager;
import com.threerings.orth.peer.server.OrthPeerManager;
import com.threerings.orth.room.server.OrthSceneFactory;
import com.threerings.orth.room.server.OrthSceneRegistry;
import com.threerings.orth.room.server.persist.OrthSceneRepository;
import com.threerings.orth.world.server.WorldManager;

/**
 * Extends the main server class with Orth functionality.
 */
@Singleton
public class OrthServer extends CrowdServer
{
    /** Configures dependencies needed by the Orth servers. */
    public static class OrthModule extends CrowdModule
    {
        @Override protected void configure () {
            super.configure();

            // whirled
            bind(SceneRepository.class).to(OrthSceneRepository.class);
            bind(SceneRegistry.class).to(OrthSceneRegistry.class);
            bind(SceneFactory.class).to(OrthSceneFactory.class);
            bind(SceneRegistry.ConfigFactory.class).to(OrthSceneFactory.class);

            // presents
            bind(PeerManager.class).to(OrthPeerManager.class);
        }
    }

    @Override
    public void init (Injector injector)
        throws Exception
    {
        super.init(injector);

        _aetherMan.init();
        _worldMan.init();
        
    }    

    @Inject protected AetherManager _aetherMan;
    @Inject protected WorldManager _worldMan;
    @Inject protected OrthSceneRegistry _sceneReg;
}

