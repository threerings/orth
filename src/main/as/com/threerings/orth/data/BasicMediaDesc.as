// GENERATED PREAMBLE START
//
// $Id$

package com.threerings.orth.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

import com.threerings.orth.data.MediaDescImpl;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class BasicMediaDesc extends MediaDescImpl
{
// GENERATED CLASSDECL END

    override public function getMimeType () :int
    {
        return _mimeType;
    }

    override public function getConstraint () :int
    {
        return _constraint;
    }

    override public function get mimeType () :int
    {
        return _mimeType;
    }

    override public function get constraint () :int
    {
        return _constraint;
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
