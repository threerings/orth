//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.peer.data;

import com.threerings.presents.peer.data.ClientInfo;

import com.threerings.orth.aether.data.AetherClientObject;
import com.threerings.orth.data.PlayerName;
import com.threerings.orth.locus.data.Locus;

/**
 * Contains information on a player logged into one of our peer servers.
 */
public class OrthClientInfo extends ClientInfo
{
    /** For Vault clients, the player's visible name. */
    public PlayerName visibleName;
}
