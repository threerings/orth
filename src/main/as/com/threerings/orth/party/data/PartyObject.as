// GENERATED PREAMBLE START
//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.


package com.threerings.orth.party.data {

import org.osflash.signals.Signal;

import com.threerings.io.ObjectInputStream;

import com.threerings.util.Cloneable;
import com.threerings.util.Util;

import com.threerings.presents.dobj.DObject;
import com.threerings.presents.dobj.DSet;
import com.threerings.presents.dobj.DSet_Entry;

import com.threerings.orth.party.data.PartyMarshaller;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class PartyObject extends DObject
    implements Cloneable
{
// GENERATED CLASSDECL END

    /** A message sent to indicate a notification that should be dispatched to all partiers.
     * Format: [ Notification ]. */
    public static const NOTIFICATION :String = "notification";

// GENERATED STREAMING START
    public var id :int;

    public var name :String;

    public var peeps :DSet;

    public var leaderId :int;

    public var sceneId :int;

    public var status :String;

    public var statusType :int;

    public var recruitment :int;

    public var disband :Boolean;

    public var partyService :PartyMarshaller;

    public var idChanged :Signal = new Signal(int, int);
    public var nameChanged :Signal = new Signal(String, String);
    public var peepsChanged :Signal = new Signal(DSet, DSet);
    public var peepsEntryAdded :Signal = new Signal(DSet_Entry);
    public var peepsEntryRemoved :Signal = new Signal(DSet_Entry);
    public var peepsEntryUpdated :Signal = new Signal(DSet_Entry, DSet_Entry);
    public var leaderIdChanged :Signal = new Signal(int, int);
    public var sceneIdChanged :Signal = new Signal(int, int);
    public var statusChanged :Signal = new Signal(String, String);
    public var statusTypeChanged :Signal = new Signal(int, int);
    public var recruitmentChanged :Signal = new Signal(int, int);
    public var disbandChanged :Signal = new Signal(Boolean, Boolean);
    public var partyServiceChanged :Signal = new Signal(PartyMarshaller, PartyMarshaller);

    public static const ID :String = "id";

    public static const NAME :String = "name";

    public static const PEEPS :String = "peeps";

    public static const LEADER_ID :String = "leaderId";

    public static const SCENE_ID :String = "sceneId";

    public static const STATUS :String = "status";

    public static const STATUS_TYPE :String = "statusType";

    public static const RECRUITMENT :String = "recruitment";

    public static const DISBAND :String = "disband";

    public static const PARTY_SERVICE :String = "partyService";

    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        id = ins.readInt();
        name = ins.readField(String);
        peeps = ins.readObject(DSet);
        leaderId = ins.readInt();
        sceneId = ins.readInt();
        status = ins.readField(String);
        statusType = ins.readByte();
        recruitment = ins.readByte();
        disband = ins.readBoolean();
        partyService = ins.readObject(PartyMarshaller);
    }

    public function PartyObject ()
    {
        new Signaller(this);
    }
// GENERATED STREAMING END

    public function clone () :Object
    {
        var clone :PartyObject = new PartyObject();
        Util.init(clone, this);
        clone.peeps = DSet(this.peeps.clone());
        clone.partyService = null;
        return clone;
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

import com.threerings.orth.party.data.PartyObject;

class Signaller
    implements AttributeChangeListener, SetListener, ElementUpdateListener, OidListListener
{
    public function Signaller (obj :PartyObject)
    {
        _obj = obj;
        _obj.addListener(this);
    }

    public function attributeChanged (event :AttributeChangedEvent) :void
    {
        var signal :Signal;
        switch (event.getName()) {
            case "id":
                signal = _obj.idChanged;
                break;
            case "name":
                signal = _obj.nameChanged;
                break;
            case "peeps":
                signal = _obj.peepsChanged;
                break;
            case "leaderId":
                signal = _obj.leaderIdChanged;
                break;
            case "sceneId":
                signal = _obj.sceneIdChanged;
                break;
            case "status":
                signal = _obj.statusChanged;
                break;
            case "statusType":
                signal = _obj.statusTypeChanged;
                break;
            case "recruitment":
                signal = _obj.recruitmentChanged;
                break;
            case "disband":
                signal = _obj.disbandChanged;
                break;
            case "partyService":
                signal = _obj.partyServiceChanged;
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
            case "peeps":
                signal = _obj.peepsEntryAdded;
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
            case "peeps":
                signal = _obj.peepsEntryRemoved;
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
            case "peeps":
                signal = _obj.peepsEntryUpdated;
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

    protected var _obj :PartyObject;
}
// GENERATED SIGNALLER END
