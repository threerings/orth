//
// $Id: RoomObject.as 17833 2009-08-14 23:34:17Z ray $

package com.threerings.orth.room.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.presents.dobj.DSet;
import com.threerings.util.Iterator;
import com.threerings.util.Name;

import com.threerings.whirled.spot.data.SpotSceneObject;

import com.threerings.orth.room.data.EntityMemories;
import com.threerings.orth.room.data.EntityControl;
import com.threerings.orth.room.data.MemoryChangedEvent;
import com.threerings.orth.room.data.OrthSceneMarshaller;

/**
 * Contains the distributed state of a virtual world room.
 */
public class OrthSceneObject extends SpotSceneObject
{
    // AUTO-GENERATED: FIELDS START
    /** The field name of the <code>name</code> field. */
    public static const NAME :String = "name";

    /** The field name of the <code>owner</code> field. */
    public static const OWNER :String = "owner";

    /** The field name of the <code>accessControl</code> field. */
    public static const ACCESS_CONTROL :String = "accessControl";

    /** The field name of the <code>roomService</code> field. */
    public static const ORTH_SCENE_SERVICE :String = "orthSceneService";

    /** The field name of the <code>memories</code> field. */
    public static const MEMORIES :String = "memories";

    /** The field name of the <code>controllers</code> field. */
    public static const CONTROLLERS :String = "controllers";
    // AUTO-GENERATED: FIELDS END

    /** The name of this room. */
    public var name :String;

    /** The name of the owner of this room (MemberName or GroupName). */
    public var owner :Name;

    /** Access control, as one of the ACCESS constants. Limits who can enter the scene. */
    public var accessControl :int;

    /** Our room service marshaller. */
    public var orthSceneService :OrthSceneMarshaller;

    /** Contains the memories for all entities in this room. */
    public var memories :DSet; /* of */ EntityMemories;
    MemoryChangedEvent; // references to force linkage

    /** Contains mappings for all controlled entities in this room. */
    public var controllers :DSet; /* of */ EntityControl;

    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);

        name = ins.readField(String) as String;
        owner = Name(ins.readObject());
        accessControl = ins.readByte();
        orthSceneService = OrthSceneMarshaller(ins.readObject());
        memories = DSet(ins.readObject());
        controllers = DSet(ins.readObject());
    }
}
}
