//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

// GENERATED PREAMBLE START
package com.threerings.orth.room.data {

import flash.utils.ByteArray;

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

import com.threerings.util.Joiner;
import com.threerings.util.Log;

import com.threerings.presents.dobj.DObject;
import com.threerings.presents.dobj.DSet;
import com.threerings.presents.dobj.NamedEvent;

import com.threerings.orth.room.data.EntityIdent;

// GENERATED PREAMBLE END
// GENERATED CLASSDECL START
public class MemoryChangedEvent extends NamedEvent
{
// GENERATED CLASSDECL END
    /** Suitable for unserialization. */
    public function MemoryChangedEvent ()
    {
        super(0, null);
    }

    override public function applyToObject (target :DObject) :Boolean
    {
        // simplification: we are definitionally never applied
        var set :DSet = target[_name] as DSet;
        var mems :EntityMemories = set.get(_ident) as EntityMemories;
        if (mems != null) {
            mems.setMemory(_key, _value);

        } else if (_value != null) {
            // mems == null && _value == null is kosher because we allow a memory clear
            // to be dispatched to clients even if it modifies nothing. But if _value != null..
            Log.getLog(this).warning("Request to add a memory to non-existent entry!",
                "ident", _ident, "key", _key, new Error());
        }
        return true;
    }

    override protected function notifyListener (listener :Object) :void
    {
        if (listener is MemoryChangedListener) {
            (listener as MemoryChangedListener).memoryChanged(_ident, _key, _value);
        }
    }

    override protected function toStringJoiner (j :Joiner) :void
    {
        super.toStringJoiner(j);
        j.add("ident", _ident, "key", _key, "value", _value);
    }

// GENERATED STREAMING START
    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        _ident = ins.readObject(EntityIdent);
        _key = ins.readField(String);
        _value = ins.readField(ByteArray);
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeObject(_ident);
        out.writeField(_key);
        out.writeField(_value);
    }

    protected var _ident :EntityIdent;
    protected var _key :String;
    protected var _value :ByteArray;
// GENERATED STREAMING END
// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END
