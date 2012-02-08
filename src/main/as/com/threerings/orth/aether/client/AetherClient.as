//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.aether.client {
import flashx.funk.ioc.inject;

import com.threerings.util.Log;

import com.threerings.presents.client.Client;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.dobj.DObjectManager;
import com.threerings.presents.net.BootstrapData;

import com.threerings.orth.aether.data.AetherAuthResponseData;
import com.threerings.orth.aether.data.AetherClientObject;
import com.threerings.orth.aether.data.AetherCredentials;
import com.threerings.orth.aether.data.AetherMarshaller;
import com.threerings.orth.aether.data.FriendMarshaller;
import com.threerings.orth.chat.data.TellMarshaller;
import com.threerings.orth.client.OrthDeploymentConfig;
import com.threerings.orth.client.OrthModule;
import com.threerings.orth.client.PolicyLoader;
import com.threerings.orth.client.Prefs;
import com.threerings.orth.data.AuthName;
import com.threerings.orth.data.OrthCodes;
import com.threerings.orth.data.PlayerName;

public class AetherClient extends Client
{
    public static const MODULE_PROP_NAME :String = "module";

    // reference classes that would otherwise not be linked in
    AuthName;
    AetherClientObject;
    AetherMarshaller;
    FriendMarshaller;
    TellMarshaller;

    public function AetherClient ()
    {
        const depConf :OrthDeploymentConfig = inject(OrthDeploymentConfig);

        // configure our server and port info
        setServer(depConf.aetherHost, depConf.aetherPorts);

        // then register with it, as any client would
        PolicyLoader.registerClient(this, depConf.policyPort);
        // configure our version
        setVersion(depConf.version);
        addServiceGroup(OrthCodes.AETHER_GROUP);

    }

    public function get playerName () :PlayerName
    {
        return (_plobj != null) ? _plobj.playerName : null;
    }

    public function get aetherObject () :AetherClientObject
    {
        return _plobj;
    }

    public function logonWithCredentials (creds :AetherCredentials) :Boolean
    {
        if (isLoggedOn()) {
            return false;
        }

        setCredentials(creds);
        logon();
        return true;
    }

    /** Returns the authentication token for this client if it's connected. */
    public function get sessionToken () :String
    {
       return AetherAuthResponseData(getAuthResponseData()).sessionToken;
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
        _plobj = AetherClientObject(clobj);
        super.gotClientObject(clobj);
    }

    override protected function buildClientProps ():Object
    {
        var props :Object = super.buildClientProps();
        props[MODULE_PROP_NAME] = _module;
        return props;
    }

    protected var _plobj :AetherClientObject;

    protected const _module :OrthModule = inject(OrthModule);

    private static const log :Log = Log.getLog(AetherClient);
}
}
