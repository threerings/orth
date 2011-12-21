//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.room.data;

import java.util.Set;

import javax.annotation.Generated;

import com.google.common.collect.Sets;

import com.threerings.util.Name;

import com.threerings.presents.dobj.DObject;
import com.threerings.presents.dobj.DSet;

import com.threerings.crowd.data.OccupantInfo;

import com.threerings.whirled.spot.data.SpotSceneObject;

import com.threerings.orth.chat.data.SpeakMarshaller;
import com.threerings.orth.chat.data.SpeakRouter;
import com.threerings.orth.data.PlayerName;

import static com.threerings.orth.Log.log;

public class OrthRoomObject extends SpotSceneObject
    implements SpeakRouter
{
    // AUTO-GENERATED: FIELDS START
    /** The field name of the <code>name</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String NAME = "name";

    /** The field name of the <code>owner</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String OWNER = "owner";

    /** The field name of the <code>accessControl</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String ACCESS_CONTROL = "accessControl";

    /** The field name of the <code>orthRoomService</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String ORTH_ROOM_SERVICE = "orthRoomService";

    /** The field name of the <code>orthSpeakService</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String ORTH_SPEAK_SERVICE = "orthSpeakService";

    /** The field name of the <code>memories</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String MEMORIES = "memories";
    // AUTO-GENERATED: FIELDS END

    /** The name of this room. */
    public String name;

    /** The name of the owner of this room (MemberName or GroupName). */
    public Name owner;

    /** Access control, as one of the ACCESS constants. Limits who can enter the scene. */
    public byte accessControl;

    /** Our service marshaller. */
    public OrthRoomMarshaller orthRoomService;

    /** Our speak service. */
    public SpeakMarshaller orthSpeakService;

    /** Contains the memories for all entities in this room. */
    public DSet<EntityMemories> memories = DSet.newDSet();

    @Override public DObject getSpeakObject ()
    {
        return this;
    }

    @Override public Set<Integer> getSpeakReceipients ()
    {
        Set<Integer> playerIds = Sets.newHashSetWithExpectedSize(this.occupantInfo.size());
        for (OccupantInfo info : this.occupantInfo) {
            if (info.username instanceof PlayerName) {
                playerIds.add(((PlayerName) info.username).getId());
            }
        }
        return playerIds;
    }

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
     * Requests that the <code>owner</code> field be set to the
     * specified value. The local value will be updated immediately and an
     * event will be propagated through the system to notify all listeners
     * that the attribute did change. Proxied copies of this object (on
     * clients) will apply the value change when they received the
     * attribute changed notification.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void setOwner (Name value)
    {
        Name ovalue = this.owner;
        requestAttributeChange(
            OWNER, value, ovalue);
        this.owner = value;
    }

    /**
     * Requests that the <code>accessControl</code> field be set to the
     * specified value. The local value will be updated immediately and an
     * event will be propagated through the system to notify all listeners
     * that the attribute did change. Proxied copies of this object (on
     * clients) will apply the value change when they received the
     * attribute changed notification.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void setAccessControl (byte value)
    {
        byte ovalue = this.accessControl;
        requestAttributeChange(
            ACCESS_CONTROL, Byte.valueOf(value), Byte.valueOf(ovalue));
        this.accessControl = value;
    }

    /**
     * Requests that the <code>orthRoomService</code> field be set to the
     * specified value. The local value will be updated immediately and an
     * event will be propagated through the system to notify all listeners
     * that the attribute did change. Proxied copies of this object (on
     * clients) will apply the value change when they received the
     * attribute changed notification.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void setOrthRoomService (OrthRoomMarshaller value)
    {
        OrthRoomMarshaller ovalue = this.orthRoomService;
        requestAttributeChange(
            ORTH_ROOM_SERVICE, value, ovalue);
        this.orthRoomService = value;
    }

    /**
     * Requests that the <code>orthSpeakService</code> field be set to the
     * specified value. The local value will be updated immediately and an
     * event will be propagated through the system to notify all listeners
     * that the attribute did change. Proxied copies of this object (on
     * clients) will apply the value change when they received the
     * attribute changed notification.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void setOrthSpeakService (SpeakMarshaller value)
    {
        SpeakMarshaller ovalue = this.orthSpeakService;
        requestAttributeChange(
            ORTH_SPEAK_SERVICE, value, ovalue);
        this.orthSpeakService = value;
    }

    /**
     * Requests that the specified entry be added to the
     * <code>memories</code> set. The set will not change until the event is
     * actually propagated through the system.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void addToMemories (EntityMemories elem)
    {
        requestEntryAdd(MEMORIES, memories, elem);
    }

    /**
     * Requests that the entry matching the supplied key be removed from
     * the <code>memories</code> set. The set will not change until the
     * event is actually propagated through the system.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void removeFromMemories (Comparable<?> key)
    {
        requestEntryRemove(MEMORIES, memories, key);
    }

    /**
     * Requests that the specified entry be updated in the
     * <code>memories</code> set. The set will not change until the event is
     * actually propagated through the system.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void updateMemories (EntityMemories elem)
    {
        requestEntryUpdate(MEMORIES, memories, elem);
    }

    /**
     * Requests that the <code>memories</code> field be set to the
     * specified value. Generally one only adds, updates and removes
     * entries of a distributed set, but certain situations call for a
     * complete replacement of the set value. The local value will be
     * updated immediately and an event will be propagated through the
     * system to notify all listeners that the attribute did
     * change. Proxied copies of this object (on clients) will apply the
     * value change when they received the attribute changed notification.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void setMemories (DSet<EntityMemories> value)
    {
        requestAttributeChange(MEMORIES, value, this.memories);
        DSet<EntityMemories> clone = (value == null) ? null : value.clone();
        this.memories = clone;
    }
    // AUTO-GENERATED: METHODS END

    /**
     * Do whatever's necessary to update the specified memory value.
     */
    public void updateMemory (EntityIdent ident, String key, byte[] value)
    {
        if (value == null || memories.containsKey(ident)) {
            // we're removing or already have an entry for this item, let's use our special event.
            // Note that we dispatch the event for the remove *even if there are no memories*,
            // the remove is still valid and the special event will take care of notifying
            // listeners without actually modifying anything.
            MemoryChangedEvent mce = new MemoryChangedEvent(_oid, MEMORIES, ident, key, value);
            // if we're on the authoritative server, update things immediately.
            if (_omgr != null && _omgr.isManager(this)) {
                mce.applyToObject(this);
            }
            postEvent(mce);

        } else {
            // We do not have an entry and we're adding a new value.
            // This form of the constructor marks the memories modified immediately.
            addToMemories(new EntityMemories(ident, key, value));
        }
    }

    /**
     * Extract memories from the room that match the specified item, return the
     * memories extracted, or null if none.
     */
    public EntityMemories takeMemories (EntityIdent entityIdent)
    {
        EntityMemories mems = memories.get(entityIdent);
        if (mems != null) {
            removeFromMemories(entityIdent);
        }
        return mems;
    }

    /**
     * Put the specified memories into this room.
     */
    public void putMemories (EntityMemories mems)
    {
        if (memories.contains(mems)) {
            log.warning("WTF? Room already contains memory entry",
                "room", getOid(), "entityIdent", mems.getKey(), new Exception());
            updateMemories(mems);
        } else {
            addToMemories(mems);
        }
    }

}
