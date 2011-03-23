//
// $Id: $

package com.threerings.orth.server;

import com.google.inject.Inject;
import com.google.inject.Injector;
import com.google.inject.Singleton;

import com.threerings.crowd.server.CrowdServer;
import com.threerings.orth.aether.server.AetherManager;
import com.threerings.orth.chat.server.ChatManager;
import com.threerings.orth.party.server.PartyRegistry;
import com.threerings.orth.peer.server.OrthPeerManager;
import com.threerings.orth.room.server.MemoryRepository;
import com.threerings.orth.room.server.OrthRoomManager.AmnesiacMemorySupply;
import com.threerings.orth.room.server.OrthSceneRegistry;
import com.threerings.orth.room.server.RoomAuthenticator;
import com.threerings.orth.room.server.RoomSessionFactory;
import com.threerings.orth.world.server.WorldManager;
import com.threerings.presents.peer.server.PeerManager;
import com.threerings.whirled.server.SceneRegistry;

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

            // room
            bind(MemoryRepository.class).to(AmnesiacMemorySupply.class);

            // whirled
            bind(SceneRegistry.class).to(OrthSceneRegistry.class);

            // presents
            bind(PeerManager.class).to(OrthPeerManager.class);
        }
    }

    @Override
    public void init (Injector injector)
        throws Exception
    {
        super.init(injector);

        MediaDescFactory.init(injector.getInstance(MediaDescFactory.class));

        // handle room logins
        _clmgr.addSessionFactory(injector.getInstance(RoomSessionFactory.class));
        _conmgr.addChainedAuthenticator(injector.getInstance(RoomAuthenticator.class));

        _aetherMgr.init();
        _worldMgr.init();
        _chatMgr.init();
        //_partyReg.init();
    }

    @Inject protected AetherManager _aetherMgr;
    @Inject protected WorldManager _worldMgr;
    @Inject protected ChatManager _chatMgr;
    @Inject protected OrthSceneRegistry _sceneReg;
    @Inject protected PartyRegistry _partyReg;
}

