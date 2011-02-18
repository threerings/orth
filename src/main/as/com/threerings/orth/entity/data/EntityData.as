// GENERATED PREAMBLE START
//
// $Id$

package com.threerings.orth.entity.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;
import com.threerings.io.SimpleStreamableObject;

import com.threerings.orth.data.MediaDesc;
import com.threerings.orth.entity.data.Entity;
import com.threerings.orth.room.data.EntityIdent;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class EntityData extends SimpleStreamableObject
    implements Entity
{
// GENERATED CLASSDECL END

// GENERATED STREAMING START
    public var media :MediaDesc;

    public var ident :EntityIdent;

    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        media = ins.readObject(MediaDesc);
        ident = ins.readObject(EntityIdent);
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeObject(media);
        out.writeObject(ident);
    }

// GENERATED STREAMING END

// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END

