//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

// GENERATED PREAMBLE START
package com.threerings.orth.room.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

import com.threerings.whirled.data.SceneModel;
import com.threerings.whirled.data.SceneUpdate;

import com.threerings.orth.room.data.DecorData;

// GENERATED PREAMBLE END
// GENERATED CLASSDECL START
public class SceneAttrsUpdate extends SceneUpdate
{
// GENERATED CLASSDECL END
// GENERATED STREAMING START
    public var name :String;

    public var decor :DecorData;

    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        name = ins.readField(String);
        decor = ins.readObject(DecorData);
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeField(name);
        out.writeObject(decor);
    }

// GENERATED STREAMING END

    override public function apply (model :SceneModel) :void
    {
        super.apply(model);

        var mmodel :OrthSceneModel = (model as OrthSceneModel);
        mmodel.name = name;
        mmodel.decor = decor;
    }


// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END
