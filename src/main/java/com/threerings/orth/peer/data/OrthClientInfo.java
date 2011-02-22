//
// $Id: OrthClientInfo.java 19625 2010-11-24 15:47:54Z zell $

package com.threerings.orth.peer.data;

import com.threerings.presents.peer.data.ClientInfo;

import com.threerings.orth.aether.data.PlayerName;
/**
 * Contains information on a player logged into one of our peer servers.
 */
public class OrthClientInfo extends ClientInfo
{
    public PlayerName playerName;

    /** Returns this member's unique identifier. */
    public int getMemberId ()
    {
        return playerName.getId();
    }
}
