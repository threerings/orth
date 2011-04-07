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
    public static NodeletAuthName makeKey (String dsetName, int playerId)
    {
        return new NodeletAuthName(dsetName, "", playerId);
    }

    /**
     * Creates a new auth name with the given fields.
     */
    public NodeletAuthName (String dsetName, String accountName, int id)
    {
        super(accountName, id);
        _dsetName = dsetName;
    }

    /**
     * Gets the dset name that this connection will access.
     */
    public String getDSetName ()
    {
        return _dsetName;
    }

    @Override // from Object
    public int hashCode ()
    {
        return _dsetName.hashCode() + super.hashCode();
    }

    @Override // from Object
    public boolean equals (Object other)
    {
        return super.equals(other) && ((NodeletAuthName)other)._dsetName.equals(_dsetName);
    }

    @Override // from Name
    public int compareTo (Name o)
    {
        int cmp = super.compareTo(o);
        return cmp != 0 ? cmp : ComparisonChain.start()
            .compare(((NodeletAuthName)o)._dsetName, _dsetName).result();
    }

    protected String _dsetName;
}
