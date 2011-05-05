//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.
package com.threerings.orth.client {
import flash.events.EventDispatcher;

import flashx.funk.ioc.inject;

import com.threerings.util.Log;

import com.threerings.orth.client.OrthContext;
import com.threerings.orth.room.client.RoomContext;

/**
 * The base class for communicating with MsoyControl instances
 * that live in usercode.
 */
public class ControlBackend
{
    /**
     * Initialize a backend to safely communicate with usercode.
     */
    public function init (events :EventDispatcher) :void
    {
        _sharedEvents = events;
        _sharedEvents.addEventListener("controlConnect", handleUserCodeConnect, false, 0, true);
    }

    /**
     * Call an exposed function in usercode.
     */
    public function callUserCode (name :String, ... args) :*
    {
        if (_props != null) {
            try {
                var func :Function = (_props[name] as Function);
                if (func != null) {
                    return func.apply(null, args);
                }

            } catch (err :*) {
                Log.getLog(this).warning("Error in usercode", err);
            }
        }
        return undefined;
    }

    /**
     * Did the usercode expose a function with the specified name?
     */
    public function hasUserCode (name :String) :Boolean
    {
        return (_props != null) && (_props[name] is Function);
    }

    /**
     * Shutdown and disconnect this control.
     */
    public function shutdown () :void
    {
        _sharedEvents.removeEventListener("controlConnect", handleUserCodeConnect);
        _sharedEvents = null;
        _props = null;
    }

    /**
     * Handle an event from usercode, hook us up!
     */
    protected function handleUserCodeConnect (evt :Object) :void
    {
        // older code has the properies in the top-level event, newer code in a sub-object
        var props :Object = ("props" in evt) ? evt.props : evt;

        if (_props != null) {
            // attempt to report this back to the caller, but don't worry if we can't
            // set the property, old APIs only allowed userProps and hostProps.
            try {
                props.alreadyConnected = true;
                return;
            } catch (err :Error) {
                // Let's log something for our own edification when this happens, but note well
                // that this is not an error. Old avatars could be connecting twice and coping,
                // so we don't want to break them. We use the above "alreadyConnected" property
                // to inform newer entities that they're booching it.
                Log.getLog(this).warning("Usercode connected more than once.", "backend", this);
            }
        }

        // copy down the user functions
        setUserProperties(props.userProps);
        // pass back ours
        var hostProps :Object = new Object();
        populateControlProperties(hostProps);
        var initProps :Object = new Object();
        populateControlInitProperties(initProps);
        hostProps["initProps"] = initProps;
        props.hostProps = hostProps;
    }

    /**
     * Retain a reference to the ball of functions we've received
     * from usercode.
     */
    protected function setUserProperties (o :Object) :void
    {
        _props = o;
    }

    /**
     * Populate the properties we pass back to user-code.
     */
    protected function populateControlProperties (o :Object) :void
    {
        o["startTransaction"] = startTransaction_v1;
        o["commitTransaction"] = commitTransaction_v1;
    }

    /**
     * Populate any properties that will only be needed when the control
     * is first initialized.
     */
    protected function populateControlInitProperties (o :Object) :void
    {
        // nothing by default
    }

    /**
     * Starts a transaction that will group all invocation requests into a single message.
     */
    protected function startTransaction_v1 () :void
    {
        _octx.getClient().getInvocationDirector().startTransaction();
        _rctx.getClient().getInvocationDirector().startTransaction();
    }

    /**
     * Commits a transaction started with {@link #startTransaction_v1}.
     */
    protected function commitTransaction_v1 () :void
    {
        _octx.getClient().getInvocationDirector().commitTransaction();
        _rctx.getClient().getInvocationDirector().commitTransaction();
    }

    protected const _octx :OrthContext = inject(OrthContext);
    protected const _rctx :RoomContext = inject(RoomContext);

    /** Properties populated by usercode. */
    protected var _props :Object;

    /** The event dispatcher we share with the usercode. Use a jolly! */
    protected var _sharedEvents :EventDispatcher;
}
}
