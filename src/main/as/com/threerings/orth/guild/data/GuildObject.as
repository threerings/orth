// GENERATED PREAMBLE START
//
// $Id$


package com.threerings.orth.guild.data {

import org.osflash.signals.Signal;

import com.threerings.io.ObjectInputStream;

import com.threerings.presents.dobj.DObject;
import com.threerings.presents.dobj.DSet;
import com.threerings.presents.dobj.DSet_Entry;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class GuildObject extends DObject
{
// GENERATED CLASSDECL END

// GENERATED STREAMING START
    public var members :DSet;

    public var membersChanged :Signal = new Signal(DSet, DSet);
    public var membersEntryAdded :Signal = new Signal(DSet_Entry);
    public var membersEntryRemoved :Signal = new Signal(DSet_Entry);
    public var membersEntryUpdated :Signal = new Signal(DSet_Entry, DSet_Entry);

    public static const MEMBERS :String = "members";

    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        members = ins.readObject(DSet);
    }

    public function GuildObject ()
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
import com.threerings.presents.dobj.ObjectAddedEvent;
import com.threerings.presents.dobj.ObjectRemovedEvent;
import com.threerings.presents.dobj.OidListListener;
import com.threerings.presents.dobj.SetListener;

import com.threerings.orth.guild.data.GuildObject;

class Signaller
    implements AttributeChangeListener, SetListener, ElementUpdateListener, OidListListener
{
    public function Signaller (obj :GuildObject)
    {
        _obj = obj;
        _obj.addListener(this);
    }

    public function attributeChanged (event :AttributeChangedEvent) :void
    {
        var signal :Signal;
        switch (event.getName()) {
            case "members":
                signal = _obj.membersChanged;
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
            case "members":
                signal = _obj.membersEntryAdded;
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
            case "members":
                signal = _obj.membersEntryRemoved;
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
            case "members":
                signal = _obj.membersEntryUpdated;
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

    protected var _obj :GuildObject;
}
// GENERATED SIGNALLER END
