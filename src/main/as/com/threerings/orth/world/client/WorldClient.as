//
// $Id: $
package com.threerings.orth.world.client
{
import flashx.funk.ioc.inject;

import com.threerings.crowd.client.CrowdClient;

import com.threerings.util.Name;

import com.threerings.presents.net.Credentials;

import com.threerings.orth.client.OrthDeploymentConfig;
import com.threerings.orth.client.PolicyLoader;
import com.threerings.orth.world.data.WorldCredentials;

/**
 * A client for connection to a world server. This class will autologon upon creation.
 */
public class WorldClient extends CrowdClient
{
    public function WorldClient ()
    {
        // let the policy loader know about us
        PolicyLoader.registerClient(this);

        // configure our version
        setVersion(_config.version);
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

    protected const _config :OrthDeploymentConfig = inject(OrthDeploymentConfig);
}
}
