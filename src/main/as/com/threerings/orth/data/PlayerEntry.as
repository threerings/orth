// GENERATED PREAMBLE START
//
// $Id$

package com.threerings.orth.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;
import com.threerings.util.Hashable;
import com.threerings.orth.data.OrthName;
import com.threerings.presents.dobj.DSet_Entry;
import com.threerings.orth.data.VizOrthName;
// GENERATED PREAMBLE END
// GENERATED CLASSDECL START
public class PlayerEntry implements DSet_Entry
{
// GENERATED CLASSDECL END

    /**
     * A sort function that may be used for PlayerEntrys
     */
    public static function sortByName (lhs :PlayerEntry, rhs :PlayerEntry, ... rest) :int
    {
        return OrthName.BY_DISPLAY_NAME(lhs.name, rhs.name);
    }


// GENERATED STREAMING START
    public var name :VizOrthName;

    public function readObject (ins :ObjectInputStream) :void
    {
        name = ins.readObject(VizOrthName);
    }

    public function writeObject (out :ObjectOutputStream) :void
    {
        out.writeObject(name);
    }

// GENERATED STREAMING END

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

// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END
