//
// $Id: $
package com.threerings.orth.world.client
{
import com.threerings.util.Name;

import com.threerings.presents.net.Credentials;

import com.threerings.crowd.client.CrowdClient;

import com.threerings.orth.client.OrthDeploymentConfig;
import com.threerings.orth.client.PolicyLoader;

import com.threerings.orth.world.data.WorldCredentials;

/**
 * A client for connection to a world server. This class will autologon upon creation.
 */
public class WorldClient extends CrowdClient
{
    [PostConstruct]
    public function initialize () :void
    {
        // let the policy loader know about us
        PolicyLoader.registerClient(this);

        // configure our version
        setVersion(_config.getVersion());
    }

    public function logonWithCredentials (
        host:String, ports: Array, creds :WorldCredentials) :Boolean
    {
        if (isLoggedOn()) {
            logoff(false);
        }

        // configure our server and port info
        setServer(host, ports);

        setCredentials(creds);
        logon();
        return true;
    }

    public function buildCredentials (username :Name, sessionToken :String) :Credentials
    {
        return new WorldCredentials(username, sessionToken);
    }

    [Inject] public var _config :OrthDeploymentConfig;
}
}
