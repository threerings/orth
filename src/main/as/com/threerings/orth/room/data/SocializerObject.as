// GENERATED PREAMBLE START
//
// $Id$

package com.threerings.orth.room.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;
import com.threerings.orth.room.data.ActorObject;
import org.osflash.signals.Signal;
import com.threerings.orth.data.OrthName;
import com.threerings.orth.entity.data.Avatar;
// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class SocializerObject extends ActorObject
{
// GENERATED CLASSDECL END

// GENERATED STREAMING START
    public var name :OrthName;

    public var avatar :Avatar;

    public var walkingId :int;

    public var nameChanged :Signal = new Signal(OrthName, OrthName);
    public var avatarChanged :Signal = new Signal(Avatar, Avatar);
    public var walkingIdChanged :Signal = new Signal(int, int);
    public var messageReceived :Signal = new Signal(String, Array);
    public var destroyed :Signal = new Signal();

    public static const NAME :String = "name";

    public static const AVATAR :String = "avatar";

    public static const WALKING_ID :String = "walkingId";

    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        name = ins.readObject(OrthName);
        avatar = ins.readObject(Avatar);
        walkingId = ins.readInt();
    }

    public function SocializerObject ()
    {
        new Signaller(this);
    }
// GENERATED STREAMING END

    public function getPlayerId () :int
    {
        return name.getId();
    }

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

import com.threerings.orth.room.data.SocializerObject;

class Signaller
    implements AttributeChangeListener, SetListener, ElementUpdateListener, MessageListener,
        ObjectDeathListener, OidListListener
{
    public function Signaller (obj :SocializerObject)
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
            case "avatar":
                signal = _obj.avatarChanged;
                break;
            case "walkingId":
                signal = _obj.walkingIdChanged;
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
            default:
                return;
        }
        signal.dispatch(event.getEntry());
    }

    public function entryRemoved (event :EntryRemovedEvent) :void
    {
        var signal :Signal;
        switch (event.getName()) {
            default:
                return;
        }
        signal.dispatch(event.getOldEntry());
    }

    public function entryUpdated (event :EntryUpdatedEvent) :void
    {
        var signal :Signal;
        switch (event.getName()) {
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

    protected var _obj :SocializerObject;
}
// GENERATED SIGNALLER END
