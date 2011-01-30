//
// $Id$

package com.threerings.orth.party.client;

import com.threerings.util.ActionScript;

import com.threerings.presents.client.InvocationService;

/**
 * Provides party services that are needed between peers.
 */
@ActionScript(omit=true)
public interface PeerPartyService extends InvocationService
{
    /**
     * Get party detail across nodes.
     */
    void getPartyDetail (int partyId, ResultListener rl);
}