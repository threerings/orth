//
// $Id: PetObject.java 19643 2010-11-28 22:48:23Z zell $

package com.threerings.orth.room.data;

import javax.annotation.Generated;

import com.threerings.crowd.data.BodyObject;
import com.threerings.crowd.data.OccupantInfo;
import com.threerings.crowd.data.Place;
import com.threerings.crowd.data.PlaceObject;

import com.threerings.orth.entity.data.Pet;
import com.threerings.orth.room.data.ActorObject;
import com.threerings.orth.room.data.EntityIdent;
import com.threerings.orth.room.data.EntityMemories;

/**
 * Contains the distributed state associated with a Pet.
 */
public class PetObject extends ActorObject
{
    // AUTO-GENERATED: FIELDS START
    /** The field name of the <code>pet</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String PET = "pet";

    /** The field name of the <code>actorState</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String ACTOR_STATE = "actorState";
    // AUTO-GENERATED: FIELDS END

    /** The digital item from whence this pet came. */
    public Pet pet;

    /** The current state of the body's actor, or null if unset/unknown/default. */
    public String actorState;

    /** Memories extracted from our most recently departed room. */
    public transient EntityMemories memories;

    @Override // from ActorObject
    public EntityIdent getEntityIdent ()
    {
        return pet.getIdent();
    }

    @Override // from BodyObject
    public OccupantInfo createOccupantInfo (PlaceObject plobj)
    {
        return new PetInfo(this);
    }

    @Override // from BodyObject
    public void willEnterPlace (Place place, PlaceObject plobj)
    {
        super.willEnterPlace(place, plobj);

        if (plobj instanceof OrthRoomObject && memories != null) {
            ((OrthRoomObject) plobj).putMemories(memories);
            memories = null;
        }
    }

    @Override // from BodyObject
    public void didLeavePlace (PlaceObject plobj)
    {
        super.didLeavePlace(plobj);

        if (plobj instanceof OrthRoomObject) {
            memories = ((OrthRoomObject) plobj).takeMemories(pet.getIdent());
        }
    }

    // AUTO-GENERATED: METHODS START
    /**
     * Requests that the <code>pet</code> field be set to the
     * specified value. The local value will be updated immediately and an
     * event will be propagated through the system to notify all listeners
     * that the attribute did change. Proxied copies of this object (on
     * clients) will apply the value change when they received the
     * attribute changed notification.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void setPet (Pet value)
    {
        Pet ovalue = this.pet;
        requestAttributeChange(
            PET, value, ovalue);
        this.pet = value;
    }

    /**
     * Requests that the <code>actorState</code> field be set to the
     * specified value. The local value will be updated immediately and an
     * event will be propagated through the system to notify all listeners
     * that the attribute did change. Proxied copies of this object (on
     * clients) will apply the value change when they received the
     * attribute changed notification.
     */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public void setActorState (String value)
    {
        String ovalue = this.actorState;
        requestAttributeChange(
            ACTOR_STATE, value, ovalue);
        this.actorState = value;
    }
    // AUTO-GENERATED: METHODS END
}
