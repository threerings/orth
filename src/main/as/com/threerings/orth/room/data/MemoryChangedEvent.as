//
// $Id$

package com.threerings.orth.scene.data {

import flash.utils.ByteArray;

import com.threerings.io.ObjectInputStream;
import com.threerings.util.Joiner;
import com.threerings.util.Log;

import com.threerings.presents.dobj.DObject;
import com.threerings.presents.dobj.DSet;
import com.threerings.presents.dobj.NamedEvent;

public class MemoryChangedEvent extends NamedEvent
{
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

    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        _ident = EntityIdent(ins.readObject());
        _key = (ins.readField(String) as String);
        _value = (ins.readField(ByteArray) as ByteArray);
    }

    /** The item to which this change applies. */
    protected var _ident :EntityIdent;

    /** The key that we're changing. */
    protected var _key :String;

    /** The new value, or null to indicate removal. */
    protected var _value :ByteArray;
}
}
