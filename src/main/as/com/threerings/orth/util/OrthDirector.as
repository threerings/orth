//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.util {
import flash.events.EventDispatcher;

import com.threerings.presents.client.Client;
import com.threerings.presents.client.ClientEvent;
import com.threerings.presents.client.SessionObserver;

/**
 * A version of Narya's BasicDirector that accepts a client as its lifelink,
 * rather than an obsolete context.
 */
public class OrthDirector extends EventDispatcher
    implements SessionObserver
{
    /**
     * Derived directors will need to provide the basic director with a
     * context that it can use to register itself with the necessary
     * entities.
     */
    public function OrthDirector (client :Client)
    {
        // save client
        _client = client;

        // listen for session start and end
        client.addClientObserver(this);

        // if we're already logged on, fire off a call to fetch services
        if (client.isLoggedOn()) {
            // this is a sanity check: it will fail if this post-logon initialized director claims
            // to need service groups (it must make that known prior to logon)
            registerServices(client);
            fetchServices(client);
            clientObjectUpdated(client);
        }
    }

    // documentation inherited from interface SessionObserver
    public function clientWillLogon (event :ClientEvent) :void
    {
        registerServices(_client);
    }

    // documentation inherited from interface SessionObserver
    public function clientDidLogon (event :ClientEvent) :void
    {
        fetchServices(_client);
        clientObjectUpdated(_client);
    }

    // documentation inherited from interface SessionObserver
    public function clientObjectDidChange (event :ClientEvent) :void
    {
        clientObjectUpdated(_client);
    }

    // documentation inherited from interface SessionObserver
    public function clientDidLogoff (event :ClientEvent) :void
    {
    }

    /**
     * Called in three circumstances: when a director is created and we've
     * already logged on; when we first log on and when the client object
     * changes after we've already logged on.
     */
    protected function clientObjectUpdated (client :Client) :void
    {
    }

    /**
     * If a director makes use of bootstrap invocation services which are part of a bootstrap
     * service group, it should register interest in that group here with a call to {@link
     * Client#addServiceGroup}.
     */
    protected function registerServices (client :Client) :void
    {
    }

    /**
     * Derived directors can override this method and obtain any services
     * they'll need during their operation via calls to {@link
     * Client#getService}. If the director is available, it will automatically
     * be called when the client logs on or when the director is constructed
     * if it is constructed after the client is already logged on.
     */
    protected function fetchServices (client :Client) :void
    {
    }

    /** Our client. */
    protected var _client :Client;
}
}
