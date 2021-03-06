//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

// GENERATED PREAMBLE START
package com.threerings.orth.room.data {

import flashx.funk.util.isAbstract;

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

import com.threerings.whirled.data.SceneModel;
import com.threerings.whirled.data.SceneUpdate;

import com.threerings.orth.room.data.FurniData;

// GENERATED PREAMBLE END
// GENERATED CLASSDECL START
public class FurniUpdate extends SceneUpdate
{
// GENERATED CLASSDECL END
// GENERATED STREAMING START
    public var data :FurniData;

    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        data = ins.readObject(FurniData);
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeObject(data);
    }

// GENERATED STREAMING END

    // from SceneUpdate
    override public function apply (model :SceneModel) :void
    {
        super.apply(model);
        doUpdate((model as OrthSceneModel));
    }

    protected /*abstract*/ function doUpdate (model :OrthSceneModel) :void
    {
        isAbstract();
    }

// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END
