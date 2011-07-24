//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

// GENERATED PREAMBLE START
package com.threerings.orth.aether.data {

import org.osflash.signals.Signal;

import com.threerings.io.ObjectInputStream;

import com.threerings.presents.data.ClientObject;
import com.threerings.presents.dobj.DSet;
import com.threerings.presents.dobj.DSet_Entry;

import com.threerings.orth.aether.data.VizPlayerName;
import com.threerings.orth.data.PlayerEntry;
import com.threerings.orth.nodelet.data.HostedNodelet;
import com.threerings.orth.party.data.PartyObjectAddress;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class AetherClientObject extends ClientObject
{
// GENERATED CLASSDECL END

// GENERATED STREAMING START
    public var playerName :VizPlayerName;

    public var friends :DSet;

    public var party :PartyObjectAddress;

    public var guildId :int;

    public var guild :HostedNodelet;

    public var playerNameChanged :Signal = new Signal(VizPlayerName, VizPlayerName);
    public var friendsChanged :Signal = new Signal(DSet, DSet);
    public var friendsEntryAdded :Signal = new Signal(DSet_Entry);
    public var friendsEntryRemoved :Signal = new Signal(DSet_Entry);
    public var friendsEntryUpdated :Signal = new Signal(DSet_Entry, DSet_Entry);
    public var partyChanged :Signal = new Signal(PartyObjectAddress, PartyObjectAddress);
    public var guildIdChanged :Signal = new Signal(int, int);
    public var guildChanged :Signal = new Signal(HostedNodelet, HostedNodelet);

    public static const PLAYER_NAME :String = "playerName";

    public static const FRIENDS :String = "friends";

    public static const PARTY :String = "party";

    public static const GUILD_ID :String = "guildId";

    public static const GUILD :String = "guild";

    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        playerName = ins.readObject(VizPlayerName);
        friends = ins.readObject(DSet);
        party = ins.readObject(PartyObjectAddress);
        guildId = ins.readInt();
        guild = ins.readObject(HostedNodelet);
    }

    public function AetherClientObject ()
    {
        new Signaller(this);
    }
// GENERATED STREAMING END

    /**
     * Get a sorted list of friends.
     */
    public function getSortedFriends () :Array
    {
        return friends.toArray().sort(PlayerEntry.sortByName);
    }

    /**
     * Convenience.
     */
    public function isOnlineFriend (memberId :int) :Boolean
    {
        return friends.containsKey(memberId);
    }

    /**
     * Get our unique integer reference.
     */
    public function get id () :int
    {
        return playerName.id;
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

import com.threerings.orth.aether.data.AetherClientObject;

class Signaller
    implements AttributeChangeListener, SetListener, ElementUpdateListener, OidListListener
{
    public function Signaller (obj :AetherClientObject)
    {
        _obj = obj;
        _obj.addListener(this);
    }

    public function attributeChanged (event :AttributeChangedEvent) :void
    {
        var signal :Signal;
        switch (event.getName()) {
            case "playerName":
                signal = _obj.playerNameChanged;
                break;
            case "friends":
                signal = _obj.friendsChanged;
                break;
            case "party":
                signal = _obj.partyChanged;
                break;
            case "guildId":
                signal = _obj.guildIdChanged;
                break;
            case "guild":
                signal = _obj.guildChanged;
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
            case "friends":
                signal = _obj.friendsEntryAdded;
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
            case "friends":
                signal = _obj.friendsEntryRemoved;
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
            case "friends":
                signal = _obj.friendsEntryUpdated;
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

    protected var _obj :AetherClientObject;
}
// GENERATED SIGNALLER END