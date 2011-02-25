// GENERATED PREAMBLE START
//
// $Id$

package com.threerings.orth.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

import com.threerings.orth.data.MediaDesc;
import com.threerings.orth.data.OrthName;

// GENERATED PREAMBLE END
// GENERATED CLASSDECL START
public class VizOrthName extends OrthName
{
// GENERATED CLASSDECL END
    /**
     * Returns this member's photo.
     */
    public function getPhoto () :ClientMediaDesc
    {
        return _photo;
    }

// GENERATED STREAMING START
    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        _photo = ins.readObject(ClientMediaDesc);
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeObject(_photo);
    }

    protected var _photo :ClientMediaDesc;
// GENERATED STREAMING END
// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END
