//
// Who - Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.room.data;

import com.google.common.collect.ComparisonChain;

import com.threerings.io.SimpleStreamableObject;

/**
 * Extend RoomLocus with instance information.
 */
public class InstancedRoomLocus extends RoomLocus
{
    public String instanceId;

    public InstancedRoomLocus (String instanceId, int sceneId, OrthLocation loc)
    {
        super(sceneId, loc);

        this.instanceId = instanceId;
    }

    // social rooms are hosted by instance, not by scene
    @Override public Comparable<?> getKey ()
    {
        return new Key(this);
    }

    @Override public int hashCode ()
    {
        return instanceId.hashCode() + 43*super.hashCode();
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

        public Key (InstancedRoomLocus locus)
        {
            this.instanceId = locus.instanceId;
            this.sceneId = locus.sceneId;
        }

        @Override public int compareTo (Key o) {
            return ComparisonChain.start()
                .compare(instanceId, o.instanceId)
                .compare(sceneId, o.sceneId).result();
        }
    }
}
