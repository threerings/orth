//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.
package com.threerings.orth.room.data {

import flash.utils.ByteArray;

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

import com.threerings.util.Cloneable;
import com.threerings.util.StreamableHashMap;

import com.threerings.presents.dobj.DSet_Entry;

import com.threerings.orth.room.data.EntityIdent;

// GENERATED PREAMBLE END
// GENERATED CLASSDECL START
public class EntityMemories implements DSet_Entry, Cloneable
{
// GENERATED CLASSDECL END
    public static const MAX_ENCODED_MEMORY_LENGTH :int = 4096;

// GENERATED STREAMING START
    public var ident :EntityIdent;

    public var memories :StreamableHashMap;

    public var modified :Boolean;

    public function readObject (ins :ObjectInputStream) :void
    {
        ident = ins.readObject(EntityIdent);
        memories = ins.readObject(StreamableHashMap);
        modified = ins.readBoolean();
    }

    public function writeObject (out :ObjectOutputStream) :void
    {
        out.writeObject(ident);
        out.writeObject(memories);
        out.writeBoolean(modified);
    }

// GENERATED STREAMING END

    // from interface DSet_Entry
    public function getKey () :Object
    {
        return ident;
    }

    public function clone () :Object
    {
        var clone :EntityMemories = new EntityMemories();
        clone.ident = this.ident;
        clone.memories = this.memories;
        clone.modified = this.modified;
        return clone;
    }

    public function toString () :String
    {
        return "[ident=" + ident + "]";
    }

    /**
     * Called by the MemoryChangedEvent to directly update a value already in the map.
     */
    public function setMemory (key :String, newValue :ByteArray) :void
    {
        if (newValue == null) {
            memories.remove(key);
        } else {
            memories.put(key, newValue);
        }
    }
// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END
