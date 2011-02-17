//
// $Id: $
package com.threerings.orth.world.client
{
import flashx.funk.ioc.inject;

import com.threerings.crowd.client.CrowdClient;

import com.threerings.io.TypedArray;

import com.threerings.util.Log;

import com.threerings.presents.net.Credentials;

import com.threerings.orth.client.OrthDeploymentConfig;
import com.threerings.orth.client.PolicyLoader;

/**
 * A client for connection to a world server. This class will autologon upon creation.
 */
public class WorldClient extends CrowdClient
{
    public function WorldClient ()
    {
        // let the policy loader know about us
        PolicyLoader.registerClient(this, _config.policyPort);

        // configure our version
        setVersion(_config.version);
    }

    public function logonTo (host :String, ports :TypedArray) :void
    {
        if (isLoggedOn()) {
            Log.getLog(this).warning("Client already logged on in logon()");
            logoff(false);
        }

        // configure our server and port info
        setServer(host, ports);
        setCredentials(buildCredentials());
        logon();
    }

    protected function buildCredentials () :Credentials
    {
        throw new Error("abstract");
    }

    protected const _config :OrthDeploymentConfig = inject(OrthDeploymentConfig);
}
}
