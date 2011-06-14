//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.party.server;

import com.threerings.presents.server.PresentsSession;

import com.threerings.orth.party.data.PartierObject;
import com.threerings.orth.party.data.PartyCredentials;

/**
 * Handles a partier session.
 */
public class PartySession extends PresentsSession
{
    @Override // from PresentsSession
    protected void sessionWillStart ()
    {
        super.sessionWillStart();

        // set up our partier object
        _partierObj = (PartierObject) _clobj;
        // TODO(bruno): OrthObjectAccess
        //_partierObj.setAccessController(OrthObjectAccess.USER);
        _partierObj.setPartyOid(((PartyCredentials)_areq.getCredentials()).partyId);
    }

    @Override // from PresentsSession
    protected void sessionDidEnd ()
    {
        super.sessionDidEnd();

        // clear out our partier object
        _partierObj = null;
    }

    @Override // from PresentsSession
    protected long getFlushTime ()
    {
        return 10 * 1000L; // give them just long enough to replace their session
    }

    protected PartierObject _partierObj;
}
