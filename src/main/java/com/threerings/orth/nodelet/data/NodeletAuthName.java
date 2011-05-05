//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.
package com.threerings.orth.nodelet.data;

import com.google.common.collect.ComparisonChain;

import com.threerings.orth.data.AuthName;
import com.threerings.util.Name;

/**
 * Names for clients authenticating for nodelet access. Note this class is final. This is because
 * the name keys off both the player id and the name of the {@code NodeObject} dset being accessed.
 */
public final class NodeletAuthName extends AuthName
{
    /**
     * Creates an instance that can be used as a key.
     */
    public static NodeletAuthName makeKey (Class<? extends Nodelet> nclass, int playerId)
    {
        return new NodeletAuthName(nclass, "", playerId);
    }

    /**
     * Creates a new auth name with the given fields.
     */
    public NodeletAuthName (Class<? extends Nodelet> nclass, String accountName, int id)
    {
        super(accountName, id);
        _discriminator = nclass.getSimpleName();
    }

    /**
     * Gets a short unique string corresponding to the kind of nodelet.
     */
    public String getDiscriminator ()
    {
        return _discriminator;
    }

    @Override // from Object
    public int hashCode ()
    {
        return _discriminator.hashCode() + super.hashCode();
    }

    @Override // from Object
    public boolean equals (Object other)
    {
        return super.equals(other) && ((NodeletAuthName)other)._discriminator.equals(_discriminator);
    }

    @Override // from Name
    public int compareTo (Name o)
    {
        int cmp = super.compareTo(o);
        return cmp != 0 ? cmp : ComparisonChain.start()
            .compare(((NodeletAuthName)o)._discriminator, _discriminator).result();
    }

    protected String _discriminator;
}
