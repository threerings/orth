package com.threerings.orth.guild.data;

import javax.annotation.Generated;

import com.threerings.orth.guild.client.GuildService;
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
    /** The field name of the <code>name</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String NAME = "name";

    /** The field name of the <code>members</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String MEMBERS = "members";

    /** The field name of the <code>guildService</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String GUILD_SERVICE = "guildService";
    // AUTO-GENERATED: FIELDS END

    /** The name of the guild. */
    public String name;

    /** The guild members. */
    public DSet<GuildMemberEntry> members = DSet.newDSet();

    /** The guild service. */
    public GuildService guildService;

    // AUTO-GENERATED: METHODS START
    /**
     * Requests that the <code>name</code> field be set to the
     * specified value. The local value will be updated immediately and an
     * event will be propagated through the system to notify all listeners
     * that the attribute did change. Proxied copies of this object (on
     * clients) will apply the value change when they received the
     * attribute changed notification.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void setName (String value)
    {
        String ovalue = this.name;
        requestAttributeChange(
            NAME, value, ovalue);
        this.name = value;
    }

    /**
     * Requests that the specified entry be added to the
     * <code>members</code> set. The set will not change until the event is
     * actually propagated through the system.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void addToMembers (GuildMemberEntry elem)
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
    public void updateMembers (GuildMemberEntry elem)
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
    public void setMembers (DSet<GuildMemberEntry> value)
    {
        requestAttributeChange(MEMBERS, value, this.members);
        DSet<GuildMemberEntry> clone = (value == null) ? null : value.clone();
        this.members = clone;
    }

    /**
     * Requests that the <code>guildService</code> field be set to the
     * specified value. The local value will be updated immediately and an
     * event will be propagated through the system to notify all listeners
     * that the attribute did change. Proxied copies of this object (on
     * clients) will apply the value change when they received the
     * attribute changed notification.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void setGuildService (GuildService value)
    {
        GuildService ovalue = this.guildService;
        requestAttributeChange(
            GUILD_SERVICE, value, ovalue);
        this.guildService = value;
    }
    // AUTO-GENERATED: METHODS END
}
