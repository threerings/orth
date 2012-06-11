//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

// GENERATED PREAMBLE START
package com.threerings.orth.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;
import com.threerings.io.SimpleStreamableObject;

import com.threerings.util.Cloneable;
import com.threerings.util.Hashable;
import com.threerings.util.Map;
import com.threerings.util.Maps;

import com.threerings.presents.dobj.DSet_Entry;

import com.threerings.orth.data.PlayerName;
import com.threerings.orth.data.where.InLocus;
import com.threerings.orth.data.where.Whereabouts;
import com.threerings.orth.guild.data.GuildName;
import com.threerings.orth.locus.data.Locus;

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
        return PlayerName.BY_DISPLAY_NAME(lhs.name, rhs.name);
    }

    /**
     * Given an array of PlayerEntries, figure out the dominant Locus among them, if any.
     */
    public static function majorityLocus (peeps :Array) :Locus
    {
        const counts :Map = Maps.newMapOf(Locus);
        var maxCount :int = 0;
        var maxLocus :Locus = null;
        for each (var peep :PlayerEntry in peeps) {
            if (peep.whereabouts is InLocus) {
                const locus :Locus = InLocus(peep.whereabouts).locus;
                const count :int = 1 + int(counts.get(locus));
                counts.put(locus, count);
                if (count > maxCount) {
                    maxCount = count;
                    maxLocus = locus;
                }
            }
        }
        return locus;
    }

// GENERATED STREAMING START
    public var name :PlayerName;

    public var guild :GuildName;

    public var whereabouts :Whereabouts;

    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        name = ins.readObject(PlayerName);
        guild = ins.readObject(GuildName);
        whereabouts = ins.readObject(Whereabouts);
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeObject(name);
        out.writeObject(guild);
        out.writeObject(whereabouts);
    }

// GENERATED STREAMING END

    public function get online () :Boolean
    {
        return whereabouts != null && whereabouts.isOnline();
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
            (this.name.id == (other as PlayerEntry).name.id);
    }

    override public function toString () :String
    {
        return "PlayerEntry[" + name + "]";
    }

    public function get id () :int
    {
        return this.name.id;
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
