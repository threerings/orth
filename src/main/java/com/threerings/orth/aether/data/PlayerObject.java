//
// $Id$

package com.threerings.orth.aether.data;

import javax.annotation.Generated;
import com.threerings.presents.data.ClientObject;

/**
 * The core distributed object representing the location-agnostic aspect of an Orth player.
 */
public class PlayerObject extends ClientObject
{
    // AUTO-GENERATED: FIELDS START
    /** The field name of the <code>playerName</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String PLAYER_NAME = "playerName";
    // AUTO-GENERATED: FIELDS END

    /** The name and id information for this player. */
    public VizPlayerName playerName;

    // AUTO-GENERATED: METHODS START
    /**
     * Requests that the <code>playerName</code> field be set to the
     * specified value. The local value will be updated immediately and an
     * event will be propagated through the system to notify all listeners
     * that the attribute did change. Proxied copies of this object (on
     * clients) will apply the value change when they received the
     * attribute changed notification.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void setPlayerName (VizPlayerName value)
    {
        VizPlayerName ovalue = this.playerName;
        requestAttributeChange(
            PLAYER_NAME, value, ovalue);
        this.playerName = value;
    }
    // AUTO-GENERATED: METHODS END
}
