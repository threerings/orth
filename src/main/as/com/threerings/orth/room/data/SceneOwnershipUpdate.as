// GENERATED PREAMBLE START
//
// $Id$

package com.threerings.orth.room.data {

import com.threerings.whirled.data.SceneModel;
import com.threerings.whirled.data.SceneUpdate;

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

import com.threerings.util.Name;

// GENERATED PREAMBLE END
// GENERATED CLASSDECL START
public class SceneOwnershipUpdate extends SceneUpdate
{
// GENERATED CLASSDECL END
// GENERATED STREAMING START
    public var ownerType :int;

    public var ownerId :int;

    public var ownerName :Name;

    public var lockToOwner :Boolean;

    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        ownerType = ins.readByte();
        ownerId = ins.readInt();
        ownerName = ins.readObject(Name);
        lockToOwner = ins.readBoolean();
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeByte(ownerType);
        out.writeInt(ownerId);
        out.writeObject(ownerName);
        out.writeBoolean(lockToOwner);
    }

// GENERATED STREAMING END

    override public function apply (model :SceneModel) :void
    {
        super.apply(model);

        var mmodel :OrthSceneModel = (model as OrthSceneModel);
        mmodel.ownerType = ownerType;
        mmodel.ownerId = ownerId;
        mmodel.ownerName = ownerName;
        if (lockToOwner) {
            mmodel.accessControl = OrthSceneModel.ACCESS_OWNER_ONLY;
        }
    }

// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END
