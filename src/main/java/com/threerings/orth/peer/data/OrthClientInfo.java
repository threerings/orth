//
// $Id: OrthClientInfo.java 19625 2010-11-24 15:47:54Z zell $

package com.threerings.orth.peer.data;

import com.threerings.crowd.peer.data.CrowdClientInfo;

import com.threerings.orth.data.OrthName;

/**
 * Contains information on a player logged into one of our peer servers.
 */
public class OrthClientInfo extends CrowdClientInfo
{
    /** Returns this member's unique identifier. */
    public int getMemberId ()
    {
        return ((OrthName)visibleName).getId();
    }
}
