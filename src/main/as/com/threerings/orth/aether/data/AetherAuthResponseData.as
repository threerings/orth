// GENERATED PREAMBLE START
//
// $Id$

package com.threerings.orth.aether.data {

import org.osflash.signals.Signal;

import com.threerings.io.ObjectInputStream;

import com.threerings.presents.net.AuthResponseData;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class AetherAuthResponseData extends AuthResponseData
{
// GENERATED CLASSDECL END

// GENERATED STREAMING START
    public var sessionToken :String;

    public var ident :String;

    public var warning :String;

    public var sessionTokenChanged :Signal = new Signal(String, String);
    public var identChanged :Signal = new Signal(String, String);
    public var warningChanged :Signal = new Signal(String, String);

    public static const SESSION_TOKEN :String = "sessionToken";

    public static const IDENT :String = "ident";

    public static const WARNING :String = "warning";

    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        sessionToken = ins.readField(String);
        ident = ins.readField(String);
        warning = ins.readField(String);
    }

    public function AetherAuthResponseData ()
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

import com.threerings.orth.aether.data.AetherAuthResponseData;

class Signaller
    implements AttributeChangeListener, SetListener, ElementUpdateListener, OidListListener
{
    public function Signaller (obj :AetherAuthResponseData)
    {
        _obj = obj;
        _obj.addListener(this);
    }

    public function attributeChanged (event :AttributeChangedEvent) :void
    {
        var signal :Signal;
        switch (event.getName()) {
            case "sessionToken":
                signal = _obj.sessionTokenChanged;
                break;
            case "ident":
                signal = _obj.identChanged;
                break;
            case "warning":
                signal = _obj.warningChanged;
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

    protected var _obj :AetherAuthResponseData;
}
// GENERATED SIGNALLER END
