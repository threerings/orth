//
// $Id: SceneAttrsUpdate.as 18590 2009-11-05 10:09:48Z jamie $

package com.threerings.orth.room.data {
import com.threerings.orth.entity.data.DecorData;
import com.threerings.whirled.data.SceneModel;
import com.threerings.whirled.data.SceneUpdate;

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

import com.threerings.orth.entity.data.Decor;

/**
 * Encodes a scene update that updates the attributes in the MsoySceneModel.
 * Note that this contains all attributes, even ones that have not changed.
 * In other words, a field being null doesn't mean that the field
 * isn't updated, it means the new value should be null.
 */
public class SceneAttrsUpdate extends SceneUpdate
{
    /** The new name. */
    public var name :String;

    /** New access control info. */
    public var accessControl :int;

    /** Full description of the new decor. */
    public var decor :DecorData;

    /** The new entrance location. */
    public var entrance :OrthLocation;

    override public function apply (model :SceneModel) :void
    {
        super.apply(model);

        var mmodel :OrthSceneModel = (model as OrthSceneModel);
        mmodel.name = name;
        mmodel.accessControl = accessControl;
        mmodel.decor = decor;
        mmodel.entrance = entrance;
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);

        out.writeField(name);
        out.writeByte(accessControl);
        out.writeObject(decor);
        out.writeObject(entrance);
    }

    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);

        name = (ins.readField(String) as String);
        accessControl = ins.readByte();
        decor = DecorData(ins.readObject());
        entrance = OrthLocation(ins.readObject());
    }
}
}
