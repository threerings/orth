//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

// GENERATED PREAMBLE START
package com.threerings.orth.room.data {

import org.osflash.signals.Signal;

import com.threerings.io.ObjectInputStream;

import com.threerings.util.Name;

import com.threerings.presents.dobj.DObject;
import com.threerings.presents.dobj.DSet;

import com.threerings.whirled.spot.data.SpotSceneObject;

import com.threerings.orth.chat.data.SpeakMarshaller;
import com.threerings.orth.chat.data.SpeakPlace;
import com.threerings.orth.room.data.EntityMemories;
import com.threerings.orth.room.data.OrthRoomMarshaller;

// GENERATED PREAMBLE END
// GENERATED CLASSDECL START
public class OrthRoomObject extends SpotSceneObject
    implements SpeakPlace
{
// GENERATED CLASSDECL END

    MemoryChangedEvent; // references to force linkage

// GENERATED STREAMING START
    public var name :String;

    public var owner :Name;

    public var accessControl :int;

    public var orthRoomService :OrthRoomMarshaller;

    public var orthSpeakService :SpeakMarshaller;

    public var memories :DSet; /* of */ EntityMemories;

    public var nameChanged :Signal = new Signal(String, String);
    public var ownerChanged :Signal = new Signal(Name, Name);
    public var accessControlChanged :Signal = new Signal(int, int);
    public var orthRoomServiceChanged :Signal = new Signal(OrthRoomMarshaller, OrthRoomMarshaller);
    public var orthSpeakServiceChanged :Signal = new Signal(SpeakMarshaller, SpeakMarshaller);
    public var memoriesChanged :Signal = new Signal(DSet, DSet);
    public var memoriesEntryAdded :Signal = new Signal(EntityMemories);
    public var memoriesEntryRemoved :Signal = new Signal(EntityMemories);
    public var memoriesEntryUpdated :Signal = new Signal(EntityMemories, EntityMemories);

    public static const NAME :String = "name";
    public static const OWNER :String = "owner";
    public static const ACCESS_CONTROL :String = "accessControl";
    public static const ORTH_ROOM_SERVICE :String = "orthRoomService";
    public static const ORTH_SPEAK_SERVICE :String = "orthSpeakService";
    public static const MEMORIES :String = "memories";

    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        name = ins.readField(String);
        owner = ins.readObject(Name);
        accessControl = ins.readByte();
        orthRoomService = ins.readObject(OrthRoomMarshaller);
        orthSpeakService = ins.readObject(SpeakMarshaller);
        memories = ins.readObject(DSet);
    }

    public function OrthRoomObject ()
    {
        new Signaller(this);
    }
// GENERATED STREAMING END

    // from SpeakPlace
    public function getDObject () :DObject
    {
        return this;
    }

    // from SpeakPlace
    public function getSpeakService () :SpeakMarshaller
    {
        return orthSpeakService;
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
import com.threerings.presents.dobj.ObjectAddedEvent;
import com.threerings.presents.dobj.ObjectRemovedEvent;
import com.threerings.presents.dobj.OidListListener;
import com.threerings.presents.dobj.SetListener;

import com.threerings.orth.room.data.OrthRoomObject;

class Signaller
    implements AttributeChangeListener, SetListener, ElementUpdateListener, OidListListener
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
            case "orthSpeakService":
                signal = _obj.orthSpeakServiceChanged;
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
