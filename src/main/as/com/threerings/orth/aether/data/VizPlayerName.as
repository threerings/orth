// GENERATED PREAMBLE START
//
// $Id$

package com.threerings.orth.aether.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;
import com.threerings.orth.aether.data.PlayerName;
import com.threerings.orth.data.MediaDesc;
// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class VizPlayerName extends PlayerName
{
// GENERATED CLASSDECL END

// GENERATED STREAMING START
    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        _photo = ins.readObject(MediaDesc);
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeObject(_photo);
    }

    protected var _photo :MediaDesc;
// GENERATED STREAMING END
// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END

