//
// $Id: $
package com.threerings.orth.world.client
{
import com.threerings.crowd.client.CrowdClient;

import com.threerings.util.Name;

import com.threerings.presents.net.Credentials;

import com.threerings.orth.client.PolicyLoader;
import com.threerings.orth.world.data.WorldCredentials;

/**
 * A client for connection to a world server. This class will autologon upon creation.
 */
public class WorldClient extends CrowdClient
{
    public function WorldClient (wctx :WorldContext, host :String, ports :Array,
        username :Name, sessionToken :String)
    {
        _wctx = wctx;

        // configure our version
        setVersion(_wctx.octx.deployment.getVersion());

        // configure our server and port info
        setServer(host, ports);

        // let the policy loader know about us
        PolicyLoader.registerClient(this);

        // create our credentials, which are sessionToken based
        setCredentials(buildCredentials(username, sessionToken));

        // and kick off the login procedure
        logon();
    }

    protected function buildCredentials (username :Name, sessionToken :String) :Credentials
    {
        return new WorldCredentials(username, sessionToken);
    }

    protected var _wctx :WorldContext;
}
}
