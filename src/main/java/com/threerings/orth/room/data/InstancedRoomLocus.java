//
// Who - Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.room.data;

import com.google.common.base.Objects;
import com.google.common.collect.ComparisonChain;

import com.threerings.io.SimpleStreamableObject;

/**
 * Extend RoomLocus with instance information.
 */
public class InstancedRoomLocus extends RoomLocus
{
    public String instanceId;

    public static Key makeKey (String instanceId, int sceneId)
    {
        return new Key(instanceId, sceneId);
    }

    public InstancedRoomLocus (String instanceId, int sceneId, OrthLocation loc)
    {
        super(sceneId, loc);

        this.instanceId = instanceId;
    }

    // social rooms are hosted by instance, not by scene
    @Override public Comparable<?> getKey ()
    {
        return new Key(this.instanceId, this.sceneId);
    }

    @Override public int hashCode ()
    {
        return Objects.hashCode(instanceId, super.hashCode());
    }

    @Override public boolean equals (Object other)
    {
        return (other instanceof InstancedRoomLocus) && super.equals(other) &&
            instanceId.equals(((InstancedRoomLocus) other).instanceId);
    }

    protected static class Key extends SimpleStreamableObject
        implements Comparable<Key>
    {
        public String instanceId;
        public int sceneId;

        public Key (String instanceId, int sceneId)
        {
            this.instanceId = instanceId;
            this.sceneId = sceneId;
        }

        @Override public int compareTo (Key o) {
            return ComparisonChain.start()
                .compare(instanceId, o.instanceId)
                .compare(sceneId, o.sceneId).result();
        }
    }
}
