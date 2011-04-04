//
// $Id$

package com.threerings.orth.server;

import com.google.inject.Inject;
import com.google.inject.Injector;
import com.google.inject.Singleton;
import com.google.inject.TypeLiteral;
import com.google.inject.multibindings.MapBinder;

import com.threerings.crowd.server.CrowdServer;
import com.threerings.orth.aether.server.AetherManager;
import com.threerings.orth.chat.server.ChatManager;
import com.threerings.orth.locus.server.LocusManager;
import com.threerings.orth.locus.server.LocusMaterializer;
import com.threerings.orth.party.server.PartyRegistry;
import com.threerings.orth.peer.server.OrthPeerManager;
import com.threerings.orth.room.data.RoomLocus;
import com.threerings.orth.room.server.MemoryRepository;
import com.threerings.orth.room.server.OrthRoomManager.AmnesiacMemorySupply;
import com.threerings.orth.room.server.OrthSceneRegistry;
import com.threerings.orth.room.server.RoomAuthenticator;
import com.threerings.orth.room.server.RoomSessionFactory;
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
            _materializers = MapBinder.newMapBinder(binder(),  new TypeLiteral<Class<?>>() {},
                new TypeLiteral<LocusMaterializer>() {});

            // room
            bind(MemoryRepository.class).to(AmnesiacMemorySupply.class);

            // whirled
            bind(SceneRegistry.class).to(OrthSceneRegistry.class);

            // presents
            bind(PeerManager.class).to(OrthPeerManager.class);

            _materializers.addBinding(RoomLocus.class).to(OrthSceneRegistry.class);
        }

        protected MapBinder<Class<?>, LocusMaterializer> _materializers;
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

        // TODO: add implements Lifecycle.InitComponent for ChatManager
        _chatMgr.init();

        //_partyReg.init();
    }

    @Inject protected AetherManager _aetherMgr;
    @Inject protected LocusManager _locusMgr;
    @Inject protected ChatManager _chatMgr;
    @Inject protected OrthSceneRegistry _sceneReg;
    @Inject protected PartyRegistry _partyReg;
}
