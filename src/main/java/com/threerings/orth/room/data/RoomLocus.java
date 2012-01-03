//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.room.data;

import com.google.common.base.Objects;
import com.google.common.collect.ComparisonChain;

import com.threerings.io.SimpleStreamableObject;

import com.threerings.orth.locus.data.Locus;
import com.threerings.orth.nodelet.data.Nodelet;

public class RoomLocus extends Nodelet
    implements Locus
{
    public static Key makeKey (int sceneId)
    {
        return makeKey(sceneId, null);
    }

    public static Key makeKey (int sceneId, String instanceId)
    {
        return new Key(sceneId, instanceId);
    }

    public int sceneId;

    public String instanceId;

    public OrthLocation loc;

    public RoomLocus (int sceneId, String instanceId, OrthLocation loc)
    {
        this.instanceId = instanceId;
        this.sceneId = sceneId;
        this.loc = loc;
    }

    @Override
    public Comparable<?> getKey ()
    {
        return new Key(this.sceneId, this.instanceId);
    }

    @Override public int hashCode ()
    {
        return getKey().hashCode();
    }

    @Override public boolean equals (Object other)
    {
        return (other instanceof RoomLocus) && getKey().equals(((RoomLocus) other).getKey());
    }

    protected static class Key extends SimpleStreamableObject
        implements Comparable<Key>
    {
        public int sceneId;
        public String instanceId;

        public Key (int sceneId, String instanceId)
        {
            this.instanceId = instanceId;
            this.sceneId = sceneId;
        }

        @Override public int compareTo (Key o) {
            return ComparisonChain.start()
                .compare(instanceId, o.instanceId)
                .compare(sceneId, o.sceneId).result();
        }

        @Override public int hashCode () {
            return Objects.hashCode(instanceId, sceneId);
        }

        @Override public boolean equals (Object other) {
            return (other instanceof RoomLocus.Key) &&
                Objects.equal(instanceId, ((RoomLocus.Key) other).instanceId) &&
                sceneId == ((RoomLocus.Key) other).sceneId;
        }
    }
}
