//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

// GENERATED PREAMBLE START
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
    public var avatarMedia :MediaDesc;

    public var scale :Number;

    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        avatarMedia = ins.readObject(MediaDesc);
        scale = ins.readFloat();
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeObject(avatarMedia);
        out.writeFloat(scale);
    }

// GENERATED STREAMING END

    // from Entity
    public function getAvatarMedia () :MediaDesc
    {
        return avatarMedia;
    }

    // from Entity
    public function getScale () :Number
    {
        return scale;
    }

// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END

