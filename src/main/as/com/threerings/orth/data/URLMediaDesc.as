// GENERATED PREAMBLE START
//
// $Id$

package com.threerings.orth.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

import com.threerings.orth.data.BasicMediaDesc;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class URLMediaDesc extends BasicMediaDesc
{
// GENERATED CLASSDECL END

// GENERATED STREAMING START
    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        _url = ins.readField(String);
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeField(_url);
    }

    protected var _url :String;
// GENERATED STREAMING END

    override public function getMediaPath ():String
    {
        return _url;
    }

    public function toString () :String
    {
        return "[url=" + _url + "]";
    }

// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END

