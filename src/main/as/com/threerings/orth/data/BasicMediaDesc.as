// GENERATED PREAMBLE START
//
// $Id$

package com.threerings.orth.data {

import flashx.funk.util.isAbstract;

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;
import com.threerings.io.SimpleStreamableObject;
import com.threerings.io.Streamable;

import com.threerings.orth.data.MediaDesc;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class BasicMediaDesc extends SimpleStreamableObject
    implements MediaDesc
{
// GENERATED CLASSDECL END

    public function getMimeType () :int
    {
        return _mimeType;
    }

    public function getConstraint () :int
    {
        return _constraint;
    }

    public function equals (other :Object) :Boolean
    {
        return isAbstract();
    }

// GENERATED STREAMING START
    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        _mimeType = ins.readByte();
        _constraint = ins.readByte();
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeByte(_mimeType);
        out.writeByte(_constraint);
    }

    protected var _mimeType :int;
    protected var _constraint :int;
// GENERATED STREAMING END

// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END

