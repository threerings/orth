//
// $Id$

package com.threerings.orth.server;

public interface OrthDeploymentConfig
{
    /**
     * Determine whether or not this is a development deployment.
     */
    boolean getDevelopment ();

    String getAetherHost ();

    int[] getAetherPorts ();

    String getRoomHost ();

    int[] getRoomPorts ();

    String getPartyHost ();

    int getPartyPort ();
}
