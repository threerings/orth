//
// $Id$

package com.threerings.orth.client {

import mx.core.Application;

import flash.display.Stage;

import com.threerings.presents.dobj.DObjectManager;
import com.threerings.presents.util.PresentsContext;

import com.threerings.orth.aether.client.AetherClient;

public class AetherContext
    implements PresentsContext
{
    public function AetherContext (app :Application, client :AetherClient)
    {
        _app = app;
        _client = client;
    }

    // from PresentsContext
    public function getClient () :Client
    {
        return _client;
    }

    // from PresentsContext
    public function getDObjectManager () :DObjectManager
    {
        return _client.getDObjectManager();
    }

    /**
     * Return a reference to the top-level Application.
     */
    public function getApplication () :Application
    {
        return _app;
    }

    /**
     * Return a reference to our Stage.
     */
    public function getStage () :Stage
    {
        return _app.getStage();
    }

    protected var _app :Application;
    protected var _client :AetherClient;
}
}
