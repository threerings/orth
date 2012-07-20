//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

// GENERATED PREAMBLE START
package com.threerings.orth.room.data {

import org.osflash.signals.Signal;

import com.threerings.io.ObjectInputStream;

import com.threerings.presents.dobj.DSet;

import com.threerings.orth.data.PlayerName;
import com.threerings.orth.entity.data.Avatar;
import com.threerings.orth.guild.data.GuildName;
import com.threerings.orth.room.data.ActorObject;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class SocializerObject extends ActorObject
{
// GENERATED CLASSDECL END

// GENERATED STREAMING START
    public var name :PlayerName;

    public var guild :GuildName;

    public var avatar :Avatar;

    public var avatarCache :DSet; /* of */ Avatar;

    public var walkingId :int;

    public var nameChanged :Signal = new Signal(PlayerName, PlayerName);
    public var guildChanged :Signal = new Signal(GuildName, GuildName);
    public var avatarChanged :Signal = new Signal(Avatar, Avatar);
    public var avatarCacheChanged :Signal = new Signal(DSet, DSet);
    public var avatarCacheEntryAdded :Signal = new Signal(Avatar);
    public var avatarCacheEntryRemoved :Signal = new Signal(Avatar);
    public var avatarCacheEntryUpdated :Signal = new Signal(Avatar, Avatar);
    public var walkingIdChanged :Signal = new Signal(int, int);

    public static const NAME :String = "name";
    public static const GUILD :String = "guild";
    public static const AVATAR :String = "avatar";
    public static const AVATAR_CACHE :String = "avatarCache";
    public static const WALKING_ID :String = "walkingId";

    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        name = ins.readObject(PlayerName);
        guild = ins.readObject(GuildName);
        avatar = ins.readObject(Avatar);
        avatarCache = ins.readObject(DSet);
        walkingId = ins.readInt();
    }

    public function SocializerObject ()
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

import com.threerings.orth.room.data.SocializerObject;

class Signaller
    implements AttributeChangeListener, SetListener, ElementUpdateListener, OidListListener
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
            case "guild":
                signal = _obj.guildChanged;
                break;
            case "avatar":
                signal = _obj.avatarChanged;
                break;
            case "avatarCache":
                signal = _obj.avatarCacheChanged;
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
            case "avatarCache":
                signal = _obj.avatarCacheEntryAdded;
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
            case "avatarCache":
                signal = _obj.avatarCacheEntryRemoved;
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
            case "avatarCache":
                signal = _obj.avatarCacheEntryUpdated;
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

    protected var _obj :SocializerObject;
}
// GENERATED SIGNALLER END