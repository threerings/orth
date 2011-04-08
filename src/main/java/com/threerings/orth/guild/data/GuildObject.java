package com.threerings.orth.guild.data;

import javax.annotation.Generated;
import com.threerings.orth.data.PlayerEntry;
import com.threerings.presents.dobj.DObject;
import com.threerings.presents.dobj.DSet;

public class GuildObject extends DObject
{
    // AUTO-GENERATED: FIELDS START
    /** The field name of the <code>players</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String PLAYERS = "players";
    // AUTO-GENERATED: FIELDS END

    public DSet<PlayerEntry> players;

    // AUTO-GENERATED: METHODS START
    /**
     * Requests that the specified entry be added to the
     * <code>players</code> set. The set will not change until the event is
     * actually propagated through the system.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void addToPlayers (PlayerEntry elem)
    {
        requestEntryAdd(PLAYERS, players, elem);
    }

    /**
     * Requests that the entry matching the supplied key be removed from
     * the <code>players</code> set. The set will not change until the
     * event is actually propagated through the system.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void removeFromPlayers (Comparable<?> key)
    {
        requestEntryRemove(PLAYERS, players, key);
    }

    /**
     * Requests that the specified entry be updated in the
     * <code>players</code> set. The set will not change until the event is
     * actually propagated through the system.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void updatePlayers (PlayerEntry elem)
    {
        requestEntryUpdate(PLAYERS, players, elem);
    }

    /**
     * Requests that the <code>players</code> field be set to the
     * specified value. Generally one only adds, updates and removes
     * entries of a distributed set, but certain situations call for a
     * complete replacement of the set value. The local value will be
     * updated immediately and an event will be propagated through the
     * system to notify all listeners that the attribute did
     * change. Proxied copies of this object (on clients) will apply the
     * value change when they received the attribute changed notification.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void setPlayers (DSet<PlayerEntry> value)
    {
        requestAttributeChange(PLAYERS, value, this.players);
        DSet<PlayerEntry> clone = (value == null) ? null : value.clone();
        this.players = clone;
    }
    // AUTO-GENERATED: METHODS END
}
