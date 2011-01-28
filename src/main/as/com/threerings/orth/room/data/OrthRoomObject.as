// GENERATED PREAMBLE START
//
// $Id$

package com.threerings.orth.room.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;
import com.threerings.whirled.spot.data.SpotSceneObject;
import com.threerings.presents.dobj.DSet;
import com.threerings.util.Name;
import org.osflash.signals.Signal;
import com.threerings.orth.room.data.OrthRoomMarshaller;
import com.threerings.presents.dobj.DSet_Entry;
// GENERATED PREAMBLE END
// GENERATED CLASSDECL START
public class OrthRoomObject extends SpotSceneObject
{
// GENERATED CLASSDECL END
// GENERATED STREAMING START
    public var name :String;

    public var owner :Name;

    public var accessControl :int;

    public var orthRoomService :OrthRoomMarshaller;

    public var memories :DSet;

    public var nameChanged :Signal = new Signal(String, String);
    public var ownerChanged :Signal = new Signal(Name, Name);
    public var accessControlChanged :Signal = new Signal(int, int);
    public var orthRoomServiceChanged :Signal = new Signal(OrthRoomMarshaller, OrthRoomMarshaller);
    public var memoriesChanged :Signal = new Signal(DSet, DSet);
    public var memoriesEntryAdded :Signal = new Signal(DSet_Entry);
    public var memoriesEntryRemoved :Signal = new Signal(DSet_Entry);
    public var memoriesEntryUpdated :Signal = new Signal(DSet_Entry, DSet_Entry);
    public var messageReceived :Signal = new Signal(String, Array);
    public var destroyed :Signal = new Signal();

    public static const NAME :String = "name";

    public static const OWNER :String = "owner";

    public static const ACCESS_CONTROL :String = "accessControl";

    public static const ORTH_ROOM_SERVICE :String = "orthRoomService";

    public static const MEMORIES :String = "memories";

    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        name = ins.readField(String);
        owner = ins.readObject(Name);
        accessControl = ins.readByte();
        orthRoomService = ins.readObject(OrthRoomMarshaller);
        memories = ins.readObject(DSet);
    }

    public function OrthRoomObject ()
    {
        new Signaller(this);
    }
// GENERATED STREAMING END
// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END
// GENERATED SIGNALLER START
import org.osflash.signals.Signal;

import com.threerings.presents.dobj.AttributeChangeListener;
import com.threerings.presents.dobj.AttributeChangedEvent;
import com.threerings.presents.dobj.ElementUpdateListener;
import com.threerings.presents.dobj.ElementUpdatedEvent;
import com.threerings.presents.dobj.EntryAddedEvent;
import com.threerings.presents.dobj.EntryRemovedEvent;
import com.threerings.presents.dobj.EntryUpdatedEvent;
import com.threerings.presents.dobj.MessageEvent;
import com.threerings.presents.dobj.MessageListener;
import com.threerings.presents.dobj.ObjectAddedEvent;
import com.threerings.presents.dobj.ObjectDeathListener;
import com.threerings.presents.dobj.ObjectDestroyedEvent;
import com.threerings.presents.dobj.ObjectRemovedEvent;
import com.threerings.presents.dobj.OidListListener;
import com.threerings.presents.dobj.SetListener;

import com.threerings.orth.room.data.OrthRoomObject;

class Signaller
    implements AttributeChangeListener, SetListener, ElementUpdateListener, MessageListener,
        ObjectDeathListener, OidListListener
{
    public function Signaller (obj :OrthRoomObject)
    {
        _obj = obj;
        _obj.addListener(this);
    }

    public function attributeChanged (event :AttributeChangedEvent) :void
    {
        var signal :Signal;
        switch (event.getName()) {
            case "name":
                signal = _obj.nameChanged;
                break;
            case "owner":
                signal = _obj.ownerChanged;
                break;
            case "accessControl":
                signal = _obj.accessControlChanged;
                break;
            case "orthRoomService":
                signal = _obj.orthRoomServiceChanged;
                break;
            case "memories":
                signal = _obj.memoriesChanged;
                break;
            default:
                return;
        }
        signal.dispatch(event.getValue(), event.getOldValue());
    }

    public function entryAdded (event :EntryAddedEvent) :void
    {
        var signal :Signal;
        switch (event.getName()) {
            case "memories":
                signal = _obj.memoriesEntryAdded;
                break;
            default:
                return;
        }
        signal.dispatch(event.getEntry());
    }

    public function entryRemoved (event :EntryRemovedEvent) :void
    {
        var signal :Signal;
        switch (event.getName()) {
            case "memories":
                signal = _obj.memoriesEntryRemoved;
                break;
            default:
                return;
        }
        signal.dispatch(event.getOldEntry());
    }

    public function entryUpdated (event :EntryUpdatedEvent) :void
    {
        var signal :Signal;
        switch (event.getName()) {
            case "memories":
                signal = _obj.memoriesEntryUpdated;
                break;
            default:
                return;
        }
        signal.dispatch(event.getEntry(), event.getOldEntry());
    }

    public function elementUpdated (event :ElementUpdatedEvent) :void
    {
        var signal :Signal;
        switch (event.getName()) {
            default:
                return;
        }
        signal.dispatch(event.getIndex(), event.getValue(), event.getOldValue());
    }

    public function messageReceived (event :MessageEvent) :void
    {
        _obj.messageReceived.dispatch(event.getName(), event.getArgs());
    }

    public function objectDestroyed (event :ObjectDestroyedEvent) :void
    {
        _obj.destroyed.dispatch();
    }

    public function objectAdded (event:ObjectAddedEvent) :void
    {
        var signal :Signal;
        switch (event.getName()) {
            default:
                return;
        }
        signal.dispatch(event.getOid());
    }

    public function objectRemoved (event :ObjectRemovedEvent) :void
    {
        var signal :Signal;
        switch (event.getName()) {
            default:
                return;
        }
        signal.dispatch(event.getOid());
    }

    protected var _obj :OrthRoomObject;
}
// GENERATED SIGNALLER END
//
// $Id: RoomObject.as 17833 2009-08-14 23:34:17Z ray $

package com.threerings.orth.room.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.presents.dobj.DSet;
import com.threerings.util.Name;

import com.threerings.whirled.spot.data.SpotSceneObject;

/**
 * Contains the distributed state of a virtual world room.
 */
public class OrthRoomObject extends SpotSceneObject
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
    // AUTO-GENERATED: FIELDS END

    /** The name of this room. */
    public var name :String;

    /** The name of the owner of this room (OrthName or GroupName). */
    public var owner :Name;

    /** Access control, as one of the ACCESS constants. Limits who can enter the scene. */
    public var accessControl :int;

    /** Our room service marshaller. */
    public var orthRoomService :OrthRoomMarshaller;

    /** Contains the memories for all entities in this room. */
    public var memories :DSet; /* of */ EntityMemories;
    MemoryChangedEvent; // references to force linkage

    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);

        name = ins.readField(String) as String;
        owner = Name(ins.readObject());
        accessControl = ins.readByte();
        orthRoomService = OrthRoomMarshaller(ins.readObject());
        memories = DSet(ins.readObject());
    }
}
}
