//
// $Id: MsoyClient.as 18690 2009-11-17 20:25:43Z jamie $

package com.threerings.orth.client {

import flash.display.Stage;
import flash.system.Capabilities;
import flash.system.Security;

import com.threerings.util.Log;

import com.threerings.presents.client.ClientAdapter;
import com.threerings.presents.client.ClientEvent;

import com.threerings.presents.net.Credentials;

import com.threerings.crowd.client.CrowdClient;

/**
 * A client shared by both our world and game incarnations.
 */
public /*abstract*/ class OrthClient extends CrowdClient
{
    public static const log :Log = Log.getLog(OrthClient);

    public function OrthClient (
        stage :Stage, version :String, host :String, ports :Array, socketPolicyPort :int)
    {
        super(null);
        _stage = stage;
        _socketPolicyPort = socketPolicyPort;
        
        setVersion(version);

        log.info("Starting up", "capabilities", Capabilities.serverString);

        // now create our credentials and context
        _creds = createStartupCreds(null);
        _ctx = createContext();

        // prior to logging on to a server, set up our security policy for that server
        addClientObserver(new ClientAdapter(clientWillLogon));

        // configure our server and port info
        setServer(host, ports);
    }

    /**
     * Return the Stage.
     */
    public function getStage () :Stage
    {
        return _stage;
    }

    /**
     * Any time we're about to connect to a server, this method must be called. It loads the
     * appropriate security policy file for the host in question and ensures that we don't do it
     * more than once per host (which sometimes causes weirdness).
     */
    public function willConnectToServer (hostname :String) :void
    {
        if (!_loadedPolicies[hostname]) {
            var url :String = "xmlsocket://" + hostname + ":" + _socketPolicyPort;
            log.info("Loading security policy", "url", url);
            Security.loadPolicyFile(url);
            _loadedPolicies[hostname] = true;
        }
    }

    /**
     * Called just before we logon to a server.
     */
    protected function clientWillLogon (event :ClientEvent) :void
    {
        willConnectToServer(getHostname());
    }

    /**
     * Creates the context we'll use with this client.
     */
    protected function createContext () :OrthContext
    {
        return new OrthContext(this);
    }

    /**
     * Creates the credentials that will be used to log us on.
     */
    protected function createStartupCreds (token :String) :Credentials
    {
        throw new Error("abstract");
    }

    protected var _ctx :OrthContext;
    protected var _stage :Stage;
    
    protected var _socketPolicyPort :int;

    protected var _loadedPolicies :Object = new Object();
}
}
