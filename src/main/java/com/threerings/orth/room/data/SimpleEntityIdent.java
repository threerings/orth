//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.room.data;

import com.google.common.collect.ComparisonChain;

/**
 * A fully qualified item identifier (type and integer id).
 */
public class SimpleEntityIdent
    implements EntityIdent /*, IsSerializable */
{
    public SimpleEntityIdent ()
    {
    }

    public SimpleEntityIdent (EntityType<?> type, int id)
    {
        _type = type;
        _id = id;
    }

    public int compareTo (EntityIdent o)
    {
        return ComparisonChain.start()
            .compare(_type, o.getType())
            .compare(_id, o.getId())
            .result();
    }

    public EntityType<?> getType ()
    {
        return _type;
    }

    public int getId()
    {
        return _id;
    }

    @Override // from Object
    public boolean equals (Object other)
    {
        return (other instanceof SimpleEntityIdent)
            && _type == ((SimpleEntityIdent) other).getType()
            && _id == ((SimpleEntityIdent) other).getId();
    }

    @Override // from Object
    public int hashCode ()
    {
        return (_type.toByte() * 37) | _id;
    }

    @Override
    public String toString ()
    {
        return _type + ":" + _id;
    }

    protected EntityType<?> _type;
    protected int _id;
}
