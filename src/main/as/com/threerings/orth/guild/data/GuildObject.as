//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

// GENERATED PREAMBLE START
package com.threerings.orth.guild.data {

import org.osflash.signals.Signal;

import com.threerings.io.ObjectInputStream;

import com.threerings.presents.dobj.DObject;
import com.threerings.presents.dobj.DSet;

import com.threerings.orth.chat.data.SpeakMarshaller;
import com.threerings.orth.chat.data.SpeakRouter;
import com.threerings.orth.guild.client.GuildService;
import com.threerings.orth.guild.data.GuildMemberEntry;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class GuildObject extends DObject
    implements SpeakRouter
{
// GENERATED CLASSDECL END
    GuildMemberEntry;
    GuildMarshaller;

// GENERATED STREAMING START
    public var name :String;

    public var members :DSet; /* of */ GuildMemberEntry;

    public var guildService :GuildService;

    public var guildChatService :SpeakMarshaller;

    public var nameChanged :Signal = new Signal(String, String);
    public var membersChanged :Signal = new Signal(DSet, DSet);
    public var membersEntryAdded :Signal = new Signal(GuildMemberEntry);
    public var membersEntryRemoved :Signal = new Signal(GuildMemberEntry);
    public var membersEntryUpdated :Signal = new Signal(GuildMemberEntry, GuildMemberEntry);
    public var guildServiceChanged :Signal = new Signal(GuildService, GuildService);
    public var guildChatServiceChanged :Signal = new Signal(SpeakMarshaller, SpeakMarshaller);

    public static const NAME :String = "name";
    public static const MEMBERS :String = "members";
    public static const GUILD_SERVICE :String = "guildService";
    public static const GUILD_CHAT_SERVICE :String = "guildChatService";

    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        name = ins.readField(String);
        members = ins.readObject(DSet);
        guildService = ins.readObject(GuildService);
        guildChatService = ins.readObject(SpeakMarshaller);
    }

    public function GuildObject ()
    {
        new Signaller(this);
    }
// GENERATED STREAMING END
    public function get speakObject () :DObject
    {
        return this;
    }

    public function get speakMarshaller () :SpeakMarshaller
    {
        return guildChatService;
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
            case "name":
                signal = _obj.nameChanged;
                break;
            case "members":
                signal = _obj.membersChanged;
                break;
            case "guildService":
                signal = _obj.guildServiceChanged;
                break;
            case "guildChatService":
                signal = _obj.guildChatServiceChanged;
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
