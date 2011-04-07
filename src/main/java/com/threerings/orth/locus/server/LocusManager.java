//
// $Id$

package com.threerings.orth.locus.server;

import java.util.Map;

import com.google.common.base.Preconditions;
import com.google.common.collect.Maps;
import com.google.inject.Inject;
import com.google.inject.Injector;
import com.google.inject.Singleton;

import com.samskivert.util.ResultListener;
import com.threerings.orth.data.OrthCodes;
import com.threerings.orth.locus.client.LocusService.LocusMaterializationListener;
import com.threerings.orth.locus.data.Locus;
import com.threerings.orth.locus.data.LocusMarshaller;
import com.threerings.orth.nodelet.data.HostedNodelet;
import com.threerings.orth.nodelet.data.Nodelet;
import com.threerings.orth.nodelet.server.NodeletRegistry;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.server.InvocationException;
import com.threerings.presents.server.InvocationManager;

@Singleton
public class LocusManager
    implements LocusProvider
{
    @Inject
    public LocusManager (InvocationManager invmgr, Injector injector,
            Map<Class<?>, LocusMaterializer> materializers)
    {
        invmgr.registerProvider(this, LocusMarshaller.class, OrthCodes.LOCUS_GROUP);
        for (Map.Entry<Class<?>, LocusMaterializer> entry : materializers.entrySet()) {
            LocusRegistry reg = new LocusRegistry(entry.getValue());
            injector.injectMembers(reg);
            _registries.put(entry.getKey(), reg);
        }
    }

    @Override
    public void materializeLocus (ClientObject caller, Locus locus,
            final LocusMaterializationListener listener)
        throws InvocationException
    {
        LocusRegistry reg = _registries.get(locus.getClass());
        Preconditions.checkNotNull(reg, "No registry for locus '%s' of class '%s'",
            locus, locus.getClass());
        reg.materialize(caller, locus, new ResultListener<HostedNodelet>() {
            @Override public void requestCompleted (HostedNodelet locus) {
                listener.locusMaterialized(locus);
            }

            @Override public void requestFailed (Exception cause) {
                listener.requestFailed(cause.getMessage());
            }
        });
    }

    protected static class LocusRegistry extends NodeletRegistry
    {
        public LocusRegistry (LocusMaterializer materializer)
        {
            super(materializer.getDSetName());
            _materializer = materializer;
        }

        @Override
        protected void host (ClientObject caller, Nodelet nodelet,
            ResultListener<HostedNodelet> listener)
        {
            _materializer.materializeLocus(caller, (Locus)nodelet, listener);
        }

        protected LocusMaterializer _materializer;
    }

    protected Map<Class<?>, LocusRegistry> _registries = Maps.newHashMap();
}
