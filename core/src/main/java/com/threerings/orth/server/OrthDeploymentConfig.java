//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

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

    String getGuildHost ();

    int[] getGuildPorts ();
}
