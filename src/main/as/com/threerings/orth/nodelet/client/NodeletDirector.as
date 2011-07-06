//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

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

import com.threerings.orth.aether.data.AetherClientObject;
import com.threerings.orth.client.OrthContext;
import com.threerings.orth.client.OrthDeploymentConfig;
import com.threerings.orth.client.PolicyLoader;
import com.threerings.orth.nodelet.data.HostedNodelet;
import com.threerings.orth.nodelet.data.Nodelet;
import com.threerings.orth.nodelet.data.NodeletAuthName;
import com.threerings.orth.nodelet.data.NodeletBootstrapData;
import com.threerings.orth.nodelet.data.NodeletCredentials;

/**
 * Connects to a nodelet on the server and provides methods, taking care of the generic
 * interfacing with presents. Subclasses are expected to provide more specific features.
 * TODO: this is designed mainly with guilds in mind; make more generic
 */
public class NodeletDirector extends BasicDirector
{
    NodeletAuthName;

    /**
     * Creates a new nodelet director using the given dsetName. The dsetName corresponds to one
     * of the DSet<HostedNodelet> members on the server's PeerNodeObject.
     */
    public function NodeletDirector ()
    {
        super(new Context(createClient()));

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

    /**
     * Creates the client to use in making this nodelet connection. By default creates a vanilla
     * presents client.
     */
    protected function createClient () :Client
    {
        return new Client();
    }

    /**
     * Called whenever the aether player object is changed. It is expected that nodelet
     * directors will want to respond to this in some way. Typically, subclasses should
     * have an override something like this:
     * <listing version="3.0">
     *     override protected function refreshPlayer () :void
     *     {
     *         if (_plobj != null) {
     *             // clean up associated with _plobbj
     *         }
     *         super.refreshPlayer();
     *         if (_plobj != null) {
     *             // start using _plobj
     *         }
     *     }
     * </listing>
     */
    protected function refreshPlayer () :void
    {
        _plobj = _octx.aetherObject;
    }

    /**
     * Logs off the current nodelet connection and connects to the given one. When the new
     * nodelet DObject is available, objectAvailable will be called.
     */
    protected function connect (nodelet :HostedNodelet) :void
    {
        // TODO: avoid churn if some of the old data is applicable to the new nodelet
        if (_sub != null) {
            if (_ctx.getDObjectManager() != null) {
                _sub.unsubscribe(_ctx.getDObjectManager());
            }
            _sub = null;
            _nodelet = null;
        }

        if (_ctx.getClient().isLoggedOn()) {
            _ctx.getClient().logoff(false);
        }

        if (_plobj == null || nodelet == null) {
            return;
        }

        var creds :NodeletCredentials = new NodeletCredentials();
        creds.nodelet = nodelet.nodelet;
        creds.sessionToken = _octx.aetherClient.sessionToken;
        _ctx.getClient().setCredentials(creds);
        _ctx.getClient().setServer(nodelet.host, nodelet.ports);
        _ctx.getClient().logon();

        _nodelet = nodelet;
    }

    /**
     * Disconnects from the current nodelet, if any.
     */
    protected function disconnect () :void
    {
        connect(null);
    }

    // from BasicDirector
    override protected function clientObjectUpdated (client :Client) :void
    {
        // subscribe to the new object, if we have it in the bootstrap data
        var nbd :NodeletBootstrapData = NodeletBootstrapData(client.getBootstrapData());
        if (nbd.targetOid != 0) {
            // unsubscribe from the old nodelet, if any
            if (_sub != null) {
                _sub.unsubscribe(_ctx.getDObjectManager());
                _sub = null;
            }

            _sub = new SafeSubscriber(nbd.targetOid, objectAvailable, objectFailed);
            _sub.subscribe(client.getDObjectManager());
        }

        // TODO: other non-bootstrap based oid? Maybe subclasses will do that
    }

    /**
     * Called when the nodelet dobject subscription failed.
     */
    protected function objectFailed (oid :int, error :ObjectAccessError) :void
    {
        log.error("Subscription failed", "oid", oid, error);
    }

    /**
     * Called when the nodelet DObject subscription has finished and the object is ready.
     */
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
    protected var _plobj :AetherClientObject;
    protected var _nodelet :HostedNodelet; // TODO: may be better not to keep this around
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
