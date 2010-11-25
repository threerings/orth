//
// $Id$

package com.threerings.orth.scene.data {

import flash.utils.ByteArray;

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

import com.threerings.presents.dobj.DSet_Entry;

import com.threerings.util.StreamableHashMap;

public class EntityMemories
    implements DSet_Entry
{
    public static const MAX_ENCODED_MEMORY_LENGTH :int = 4096;

    /** The item with which these memories are associated. */
    public var ident :EntityIdent;

    /** The memory key/values. */
    public var memories :StreamableHashMap; // of String

    // from interface DSet_Entry
    public function getKey () :Object
    {
        return ident;
    }

    // inherited hah
    public function toString () :String
    {
        return "[ident=" + ident + "]";
    }

    // from interface Streamable
    public function readObject (ins :ObjectInputStream) :void
    {
        ident = EntityIdent(ins.readObject());
        memories = StreamableHashMap(ins.readObject());
        /* modified = */ ins.readBoolean(); // modified not needed on client, but can't be transient
    }

    // from interface Streamable
    public function writeObject (out :ObjectOutputStream) :void
    {
        throw new Error();
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
}
}
