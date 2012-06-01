//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.locus.server;

import java.util.Map;

import com.google.common.base.Preconditions;
import com.google.inject.Inject;
import com.google.inject.Injector;
import com.google.inject.Singleton;

import com.threerings.presents.data.ClientObject;
import com.threerings.presents.server.InvocationException;
import com.threerings.presents.server.InvocationManager;

import com.threerings.orth.aether.data.AetherClientObject;
import com.threerings.orth.aether.server.AetherNodeAction;
import com.threerings.orth.data.AuthName;
import com.threerings.orth.data.OrthCodes;
import com.threerings.orth.data.where.InLocus;
import com.threerings.orth.locus.client.LocusService.LocusMaterializationListener;
import com.threerings.orth.locus.data.Locus;
import com.threerings.orth.locus.data.LocusMarshaller;
import com.threerings.orth.peer.server.OrthPeerManager;

@Singleton
public class LocusManager
    implements LocusProvider
{
    @Inject
    public LocusManager (InvocationManager invmgr, Injector injector)
    {
        invmgr.registerProvider(this, LocusMarshaller.class, OrthCodes.LOCUS_GROUP);
    }

    @Override
    public void materializeLocus (final AetherClientObject caller, Locus locus,
           final LocusMaterializationListener listener)
        throws InvocationException
    {
        specializedMaterializeLocus(caller, locus, listener);
    }

    // We can't provide the generic type in materializeLocus as its signature has to match
    // LocusProvider's, and LocusProvider can't be generated with the generic type. That means we
    // need this specialization method to make the call to materializer valid.
    protected <L extends Locus> void specializedMaterializeLocus (ClientObject caller, L locus,
        LocusMaterializationListener listener)
    {
        @SuppressWarnings("unchecked")
        LocusMaterializer<L> materializer = (LocusMaterializer<L>)_materializers.get(locus.getClass());
        Preconditions.checkNotNull(materializer, "No materializer for locus '%s' of class '%s'",
            locus, locus.getClass());
        materializer.materializeLocus(caller, locus, listener);
    }

    /**
     * Let the Locus system know a player has successfully arrived at a new Locus. This is
     * typically called from a dependable server object such as e.g. a PlaceManager, where we
     * can state with authoritaty that the move has completed successfully.
     *
     * Avoid calling this method when "we're pretty sure the move will finish", or, god forbid,
     * directly from the client.
     */
    public void noteLocusForPlayer (AuthName name, final InLocus whereabouts)
    {
        // update the cross-peer information
        _peerMgr.updateWhereabouts(name, whereabouts);

        // update the player's vault
        _peerMgr.invokeNodeAction(new AetherNodeAction(name.getId()) {
            @Override protected void execute (AetherClientObject memobj) {
                memobj.setLocus(whereabouts.getLocus());
            }
        });
    }

    @Inject protected Map<Class<?>, LocusMaterializer<?>> _materializers;

    @Inject protected OrthPeerManager _peerMgr;
}
