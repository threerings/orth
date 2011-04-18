// GENERATED PREAMBLE START
//
// $Id$


package com.threerings.orth.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;
import com.threerings.io.SimpleStreamableObject;

import com.threerings.util.Cloneable;
import com.threerings.util.Hashable;

import com.threerings.presents.dobj.DSet_Entry;

import com.threerings.orth.aether.data.VizPlayerName;
import com.threerings.orth.data.OrthName;

// GENERATED PREAMBLE END
// GENERATED CLASSDECL START
public class PlayerEntry extends SimpleStreamableObject
    implements DSet_Entry, Cloneable
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
    public var name :VizPlayerName;

    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        name = ins.readObject(VizPlayerName);
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
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

    override public function toString () :String
    {
        return "PlayerEntry[" + name + "]";
    }

    // from interface DSet_Entry
    public function getKey () :Object
    {
        return this.name.getKey();
    }

    // from interface Cloneable
    public function clone () : Object
    {
        var entry :PlayerEntry = new PlayerEntry();
        entry.name = this.name;
        return entry;
    }

// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END
