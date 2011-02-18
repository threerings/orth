// GENERATED PREAMBLE START
//
// $Id$

package com.threerings.orth.entity.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

import com.threerings.orth.data.MediaDesc;
import com.threerings.orth.entity.data.Avatar;
import com.threerings.orth.entity.data.EntityData;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class AvatarData extends EntityData
    implements Avatar
{
// GENERATED CLASSDECL END

// GENERATED STREAMING START
    public var media :MediaDesc;

    public var scale :Number;

    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        media = ins.readObject(MediaDesc);
        scale = ins.readFloat();
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeObject(media);
        out.writeFloat(scale);
    }

// GENERATED STREAMING END

// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END

