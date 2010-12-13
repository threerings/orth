package com.threerings.orth.client
{
import com.threerings.presents.net.AuthResponseData;
import com.threerings.presents.util.PresentsContext;

import mx.core.Application;

public interface OrthContext
    extends PresentsContext
{
    /**
     * Saves the session token communicated via the supplied auth response. It is stored in the
     * credentials of the client so that we can log in more efficiently on a reconnect, and so that
     * we can log into game servers.
     */
    function saveSessionToken (arsp :AuthResponseData) :void;

    function getApplication () :Application;

    /**
     * Let us know whether or not this is a development environment.
     */
    function isDevelopment () :Boolean;

    /**
     * Return the compiled version identifier for this client. This value is sent over the wire
     * to validate with the server.
     */
    function getVersion () :String;
}
}
