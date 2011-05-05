//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.room.data;

import java.util.Set;
import javax.annotation.Generated;

import com.threerings.crowd.data.BodyObject;

import com.threerings.whirled.data.ScenePlace;

/**
 * Contains additional information for a body in Whirled.
 */
public abstract class ActorObject extends BodyObject
{
    // AUTO-GENERATED: FIELDS START
    /** The field name of the <code>actorState</code> field. */
    @Generated(value={"com.threerings.presents.tools.GenDObjectTask"})
    public static final String ACTOR_STATE = "actorState";
    // AUTO-GENERATED: FIELDS END

    /** The current state of the body's actor, or null if unset/unknown/default. */
    public String actorState;

    /**
     * Returns the scene occupied by this body.
     *
     * @see ScenePlace#getSceneId
     */
    public int getSceneId ()
    {
        return ScenePlace.getSceneId(this);
    }

    /**
     * Determines whether this body is allowed to enter the specified scene. By default all bodies
     * are allowed in all scenes. Only members are further restricted.
     */
    public boolean canEnterScene (
        int sceneId, int ownerId, byte ownerType, byte accessControl, Set<Integer> friendIds)
    {
        return true;
    }

    public abstract EntityIdent getEntityIdent ();

    // AUTO-GENERATED: METHODS START
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
