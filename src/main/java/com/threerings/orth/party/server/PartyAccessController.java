//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.party.server;

import com.threerings.presents.dobj.AccessController;
import com.threerings.presents.dobj.DEvent;
import com.threerings.presents.dobj.DObject;
import com.threerings.presents.dobj.ProxySubscriber;
import com.threerings.presents.dobj.Subscriber;
import com.threerings.presents.server.PresentsObjectAccess;

import com.threerings.orth.party.data.PartierObject;
import com.threerings.orth.party.data.PartyObject;

public class PartyAccessController implements AccessController
{
    public PartyAccessController (PartyManager mgr)
    {
        _mgr = mgr;
    }

    // from AccessController
    public boolean allowSubscribe (DObject object, Subscriber<?> sub)
    {
        // if the subscriber is a client, ensure that they are in this party
        if (sub instanceof ProxySubscriber) {
            PartierObject partier = (PartierObject)((ProxySubscriber)sub).getClientObject();
            PartyObject party = (PartyObject)object;
            boolean maySubscribe = (partier.partyOid == party.getOid());
            if (maySubscribe) {
                _mgr.clientSubscribed(partier);
            }
            return maySubscribe;
        }

        // else: server
        return true;
    }

    // from AccessController
    public boolean allowDispatch (DObject object, DEvent event)
    {
        return PresentsObjectAccess.DEFAULT.allowDispatch(object, event);
    }

    protected PartyManager _mgr;
}
