//
// $Id: PlayerEntry.as 19627 2010-11-24 16:02:41Z zell $

package com.threerings.orth.data {

import com.threerings.io.ObjectOutputStream;
import com.threerings.io.ObjectInputStream;

import com.threerings.util.Hashable;

import com.threerings.orth.data.OrthName;

import com.threerings.presents.dobj.DSet_Entry;

/**
 * Represents a friend connection.
 */
public class PlayerEntry
    implements Hashable, DSet_Entry
{
    /** The display name of the friend. */
    public var name :OrthName;

    /**
     * A sort function that may be used for PlayerEntrys
     */
    public static function sortByName (lhs :PlayerEntry, rhs :PlayerEntry, ... rest) :int
    {
        return OrthName.BY_DISPLAY_NAME(lhs.name, rhs.name);
    }

    // from Hashable
    public function hashCode () :int
    {
        return this.name.hashCode();
    }

    // from Hashable
    public function equals (other :Object) :Boolean
    {
        return (other is PlayerEntry) &&
            (this.name.getId() == (other as PlayerEntry).name.getId());
    }

    public function toString () :String
    {
        return "PlayerEntry[" + name + "]";
    }

    // from interface DSet_Entry
    public function getKey () :Object
    {
        return this.name.getKey();
    }

    // from interface Streamable
    public function readObject (ins :ObjectInputStream) :void
    {
        name = OrthName(ins.readObject());
    }

    // from interface Streamable
    public function writeObject (out :ObjectOutputStream) :void
    {
        out.writeObject(name);
    }
}
}
