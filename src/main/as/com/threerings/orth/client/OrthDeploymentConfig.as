//
// $Id$

package com.threerings.orth.client {

public interface OrthDeploymentConfig
{
    /**
     * Return the version identifier of the current client. This is sent over the wire to the
     * presents system to validate against the server version.
     */
    function getVersion () :String;

    /**
     * Determine whether or not this is a development deployment.
     */
    function isDevelopment () :Boolean;
}
}
