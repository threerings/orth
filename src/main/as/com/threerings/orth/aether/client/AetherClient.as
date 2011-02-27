//
// $Id$

package com.threerings.orth.aether.client {

import flashx.funk.ioc.inject;

import com.threerings.util.Log;

import com.threerings.presents.client.Client;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.dobj.DObjectManager;
import com.threerings.presents.net.BootstrapData;

import com.threerings.orth.aether.data.AetherAuthResponseData;
import com.threerings.orth.aether.data.AetherCredentials;
import com.threerings.orth.aether.data.PlayerMarshaller;
import com.threerings.orth.aether.data.PlayerObject;
import com.threerings.orth.client.OrthDeploymentConfig;
import com.threerings.orth.client.PolicyLoader;
import com.threerings.orth.client.Prefs;
import com.threerings.orth.data.AuthName;

public class AetherClient extends Client
{
    // reference classes that would otherwise not be linked in
    AuthName;
    PlayerObject;
    PlayerMarshaller;

    public function AetherClient ()
    {
        const depConf :OrthDeploymentConfig = inject(OrthDeploymentConfig);

        // configure our server and port info
        setServer(depConf.aetherHost, depConf.aetherPorts);

        // then register with it, as any client would
        PolicyLoader.registerClient(this, depConf.policyPort);
        // configure our version
        setVersion(depConf.version);
    }

    public function getPlayerObject () :PlayerObject
    {
        return _plobj;
    }

    public function logonWithCredentials (creds :AetherCredentials) :Boolean
    {
        if (isLoggedOn()) {
            return false;
        }

        Prefs.setUsername(creds.getUsername().toString());

        creds.ident = Prefs.getMachineIdent();
        setCredentials(creds);
        logon();
        return true;
    }

    // from Client
    override public function gotBootstrap (data :BootstrapData, omgr :DObjectManager) :void
    {
        super.gotBootstrap(data, omgr);

        // save any machineIdent or sessionToken from the server.
        var rdata :AetherAuthResponseData = AetherAuthResponseData(getAuthResponseData());
        if (rdata.ident != null) {
            Prefs.setMachineIdent(rdata.ident);
        }
        if (rdata.sessionToken != null) {
            // TODO - scoped injection
            //_injector.mapValue(String, rdata.sessionToken, "sessionToken");
        }
    }

    override public function gotClientObject (clobj :ClientObject):void
    {
        super.gotClientObject(clobj);

        _plobj = PlayerObject(clobj);
    }

    protected var _plobj :PlayerObject;

    private static const log :Log = Log.getLog(AetherClient);
}
}
