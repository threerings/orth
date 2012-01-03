//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.instance.data;

public interface InstanceBody
{
    public void addedTo (Instance instance);
    public void removedFrom (Instance instance);
}
