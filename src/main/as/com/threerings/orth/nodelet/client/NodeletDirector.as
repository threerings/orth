package com.threerings.orth.nodelet.client
{
import flashx.funk.ioc.inject;

import as3isolib.data.Node;

import com.threerings.util.Log;

import com.threerings.presents.client.BasicDirector;
import com.threerings.presents.client.Client;
import com.threerings.presents.client.ClientEvent;
import com.threerings.presents.dobj.DObject;
import com.threerings.presents.dobj.ObjectAccessError;
import com.threerings.presents.util.SafeSubscriber;

import com.threerings.orth.aether.data.AetherAuthResponseData;
import com.threerings.orth.aether.data.PlayerObject;
import com.threerings.orth.client.OrthContext;
import com.threerings.orth.client.OrthDeploymentConfig;
import com.threerings.orth.client.PolicyLoader;
import com.threerings.orth.data.TokenCredentials;
import com.threerings.orth.nodelet.data.HostedNodelet;
import com.threerings.orth.nodelet.data.Nodelet;
import com.threerings.orth.nodelet.data.NodeletBootstrapData;

public class NodeletDirector extends BasicDirector
{
    public function NodeletDirector (dsetName :String)
    {
        super(new Context(createClient()));
        _dsetName = dsetName;

        PolicyLoader.registerClient(_ctx.getClient(), _config.policyPort);
        _ctx.getClient().setVersion(_config.version);

        function doRefresh (..._) :void {
            refreshPlayer();
        }

        _octx.getClient().addEventListener(ClientEvent.CLIENT_DID_LOGON, doRefresh);
        _octx.getClient().addEventListener(ClientEvent.CLIENT_DID_LOGOFF, doRefresh);
        _octx.getClient().addEventListener(ClientEvent.CLIENT_OBJECT_CHANGED, doRefresh);

        refreshPlayer();
    }

    public function createClient () :Client
    {
        return new Client();
    }

    protected function refreshPlayer () :void
    {
        _plobj = _octx.getPlayerObject();
    }

    protected function connect (nodelet :HostedNodelet) :void
    {
        // TODO: avoid churn if some of the old data is applicable to the new nodelet
        if (_sub != null) {
            _sub.unsubscribe(_ctx.getDObjectManager());
            _sub = null;
            _nodelet = null;
        }

        if (_ctx.getClient().isLoggedOn()) {
            _ctx.getClient().logoff(false);
        }

        if (_plobj == null || nodelet == null) {
            return;
        }

        var creds :TokenCredentials = new TokenCredentials();
        creds.subsystemId = _dsetName;
        creds.objectId = nodelet.nodelet.getId();
        creds.sessionToken = getAuthToken();
        _ctx.getClient().setCredentials(creds);
        _ctx.getClient().logon();

        _nodelet = nodelet;
    }

    protected function disconnect () :void
    {
        connect(null);
    }

    protected function getAuthToken () :String
    {
        return AetherAuthResponseData(_octx.getClient().getAuthResponseData()).sessionToken;
    }

    override protected function clientObjectUpdated (client :Client) :void
    {
        if (_sub != null) {
            _sub.unsubscribe(_ctx.getDObjectManager());
            _sub = null;
        }

        var nbd :NodeletBootstrapData = NodeletBootstrapData(client.getBootstrapData());
        if (nbd.targetOid != 0) {
            _sub = new SafeSubscriber(nbd.targetOid, objectAvailable, objectFailed);
            _sub.subscribe(client.getDObjectManager());
        }
    }

    protected function objectFailed (oid :int, error :ObjectAccessError) :void
    {
        log.error("Subscription failed", "oid", oid, error);
    }

    protected function objectAvailable (obj :DObject) :void
    {
        _dobj = obj;
    }

    // from BasicDirector
    override protected function fetchServices (client :Client) :void
    {
        // TODO: service
        //_service = NodeletService(client.requireService(NodeletService));
    }

    // TODO: service
    //protected var _service :NodeletService;
    protected var _dsetName :String;
    protected var _plobj :PlayerObject;
    protected var _nodelet :HostedNodelet;
    protected var _sub :SafeSubscriber;
    protected var _dobj :DObject;

    protected var _octx :OrthContext = inject(OrthContext);
    protected const _config :OrthDeploymentConfig = inject(OrthDeploymentConfig);
    private static const log :Log = Log.getLog(NodeletDirector);
}
}

import com.threerings.presents.client.Client;
import com.threerings.presents.dobj.DObjectManager;
import com.threerings.presents.util.PresentsContext;

class Context implements PresentsContext
{
    public function Context (client :Client)
    {
        _client = client;
    }

    public function getClient () :Client
    {
        return _client;
    }

    public function getDObjectManager() :DObjectManager
    {
        return _client.getDObjectManager();
    }

    protected var _client :Client;
}
