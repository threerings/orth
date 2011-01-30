//
// $Id: PartyAuthenticator.java 19629 2010-11-24 16:40:04Z zell $

package com.threerings.orth.party.server;

import java.util.concurrent.Callable;

import com.google.inject.Inject;
import com.google.inject.Singleton;
import com.samskivert.util.ServiceWaiter;

import com.threerings.web.gwt.ServiceException;
import com.threerings.presents.server.PresentsDObjectMgr;

import com.threerings.orth.data.AuthName;
import com.threerings.orth.data.OrthAuthCodes;
import com.threerings.orth.server.AuxAuthenticator;

import com.threerings.orth.party.data.PartyAuthName;
import com.threerings.orth.party.data.PartyCodes;
import com.threerings.orth.party.data.PartyCredentials;

import static com.threerings.orth.Log.log;

/**
 * Handles partier authentication.
 */
@Singleton
public class PartyAuthenticator extends AuxAuthenticator<PartyCredentials>
{
    // fiddling to work around a circular dependency
    public void init (PartyRegistry partyReg)
    {
        _partyReg = partyReg;
    }

    protected PartyAuthenticator ()
    {
        super(PartyCredentials.class);
    }

    @Override // from AuxAuthenticator
    protected AuthName createName (String accountName, int memberId)
    {
        return new PartyAuthName(accountName, memberId);
    }

    @Override // from AuxAuthenticator
    protected void finishAuthentication (PartyCredentials creds, final OrthName name)
        throws ServiceException
    {
        final int partyId = creds.partyId;

        // now we can pre-join the party (to reserve our spot and make sure we're allowed in)
        eventCall(new Callable<Void>() {
            public Void call () throws Exception {
                _partyReg.preJoinParty(name, partyId);
                return null;
            }
        });
    }

    /**
     * Executes some code on the dobj event thread, waits for the result and returns it. Any
     * failure is rewrapped in a ServiceException.
     */
    protected <T> T eventCall (final Callable<T> callable)
        throws ServiceException
    {
        final ServiceWaiter<T> waiter = new ServiceWaiter<T>(10);
        _omgr.postRunnable(new Runnable () {
            public void run () {
                try {
                    waiter.postSuccess(callable.call());
                } catch (Exception e) {
                    waiter.postFailure(e);
                }
            }
        });

        try {
            if (!waiter.waitForResponse()) {
                throw new ServiceException(waiter.getError().getMessage());
            }
            return waiter.getArgument();
        } catch (ServiceWaiter.TimeoutException te) {
            log.warning("Party authentication timed out!", te);
            throw new ServiceException(OrthAuthCodes.SERVER_ERROR);
        }
    }

    protected PartyRegistry _partyReg;

    @Inject protected PresentsDObjectMgr _omgr;
}