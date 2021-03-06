//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.client {

public interface OrthDeploymentConfig
{
    /**
     * Return the version identifier of the current client. This is sent over the wire to the
     * presents system to validate against the server version.
     */
    function get version () :String;

    /**
     * Determine whether or not this is a development deployment.
     */
    function get development () :Boolean;

    function get buildTime () :String;

    function get aetherHost () :String;

    function get aetherPorts () :Array;

    function get policyPort () :int;
}
}
