//
// $Id$

package com.threerings.orth.client {

import flash.system.Security;

import com.threerings.util.Log;

import com.threerings.presents.client.Client;
import com.threerings.presents.client.ClientAdapter;
import com.threerings.presents.client.ClientEvent;

public class PolicyLoader
{
    public static function registerClient (client :Client, policyPort :int) :void
    {
        if (policyPort != _socketPolicyPort) {
            log.info("PolicyLoader configured.", "port", policyPort);
            _socketPolicyPort = policyPort;
        }
        client.addClientObserver(new ClientAdapter(clientWillLogon));
    }

    /**
     * Called just before we logon to a server.
     *
     * Any time we're about to connect to a server, this method must be called. It loads the
     * appropriate security policy file for the host in question and ensures that we don't do it
     * more than once per host (which sometimes causes weirdness).
     */
    protected static function clientWillLogon (event :ClientEvent) :void
    {
        var hostname :String = event.getClient().getHostname();

        if (!_loadedPolicies[hostname]) {
            var url :String = "xmlsocket://" + hostname + ":" + _socketPolicyPort;
            Log.getLog(PolicyLoader).info("Loading security policy", "url", url);
            Security.loadPolicyFile(url);
            _loadedPolicies[hostname] = true;
        }
    }

    protected static var _loadedPolicies :Object = new Object();

    protected static var _socketPolicyPort :int;

    protected static const log :Log = Log.getLog(PolicyLoader);
}
}
