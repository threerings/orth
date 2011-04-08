package com.threerings.orth.guild.data;

import javax.annotation.Generated;
import com.threerings.orth.data.PlayerEntry;
import com.threerings.presents.dobj.DObject;
import com.threerings.presents.dobj.DSet;

/**
 * Object corresponding to a player guild (a.k.a. universe in the emerging design). Guilds are
 * hosted by a peer using the nodelet system. Clients instantiate a new connection to access guild
 * information.
 */
public class GuildObject extends DObject
{
    // AUTO-GENERATED: FIELDS START
    /** The field name of the <code>members</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String MEMBERS = "members";
    // AUTO-GENERATED: FIELDS END

    public DSet<PlayerEntry> members;

    // AUTO-GENERATED: METHODS START
    /**
     * Requests that the specified entry be added to the
     * <code>members</code> set. The set will not change until the event is
     * actually propagated through the system.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void addToMembers (PlayerEntry elem)
    {
        requestEntryAdd(MEMBERS, members, elem);
    }

    /**
     * Requests that the entry matching the supplied key be removed from
     * the <code>members</code> set. The set will not change until the
     * event is actually propagated through the system.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void removeFromMembers (Comparable<?> key)
    {
        requestEntryRemove(MEMBERS, members, key);
    }

    /**
     * Requests that the specified entry be updated in the
     * <code>members</code> set. The set will not change until the event is
     * actually propagated through the system.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void updateMembers (PlayerEntry elem)
    {
        requestEntryUpdate(MEMBERS, members, elem);
    }

    /**
     * Requests that the <code>members</code> field be set to the
     * specified value. Generally one only adds, updates and removes
     * entries of a distributed set, but certain situations call for a
     * complete replacement of the set value. The local value will be
     * updated immediately and an event will be propagated through the
     * system to notify all listeners that the attribute did
     * change. Proxied copies of this object (on clients) will apply the
     * value change when they received the attribute changed notification.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void setMembers (DSet<PlayerEntry> value)
    {
        requestAttributeChange(MEMBERS, value, this.members);
        DSet<PlayerEntry> clone = (value == null) ? null : value.clone();
        this.members = clone;
    }
    // AUTO-GENERATED: METHODS END
}
