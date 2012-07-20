//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

// GENERATED PREAMBLE START
package com.threerings.orth.aether.data {

import org.osflash.signals.Signal;

import com.threerings.io.ObjectInputStream;

import com.threerings.presents.data.ClientObject;
import com.threerings.presents.dobj.DSet;

import com.threerings.orth.chat.data.ChannelEntry;
import com.threerings.orth.data.PlayerEntry;
import com.threerings.orth.data.PlayerName;
import com.threerings.orth.guild.data.GuildName;
import com.threerings.orth.locus.data.Locus;
import com.threerings.orth.nodelet.data.HostedNodelet;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class AetherClientObject extends ClientObject
{
// GENERATED CLASSDECL END

// GENERATED STREAMING START
    public var playerName :PlayerName;

    public var friends :DSet; /* of */ PlayerEntry;

    public var ignoring :DSet; /* of */ PlayerName;

    public var ignoredBy :DSet; /* of */ PlayerName;

    public var channels :DSet; /* of */ ChannelEntry;

    public var locus :Locus;

    public var party :HostedNodelet;

    public var guildName :GuildName;

    public var guild :HostedNodelet;

    public var playerNameChanged :Signal = new Signal(PlayerName, PlayerName);
    public var friendsChanged :Signal = new Signal(DSet, DSet);
    public var friendsEntryAdded :Signal = new Signal(PlayerEntry);
    public var friendsEntryRemoved :Signal = new Signal(PlayerEntry);
    public var friendsEntryUpdated :Signal = new Signal(PlayerEntry, PlayerEntry);
    public var ignoringChanged :Signal = new Signal(DSet, DSet);
    public var ignoringEntryAdded :Signal = new Signal(PlayerName);
    public var ignoringEntryRemoved :Signal = new Signal(PlayerName);
    public var ignoringEntryUpdated :Signal = new Signal(PlayerName, PlayerName);
    public var ignoredByChanged :Signal = new Signal(DSet, DSet);
    public var ignoredByEntryAdded :Signal = new Signal(PlayerName);
    public var ignoredByEntryRemoved :Signal = new Signal(PlayerName);
    public var ignoredByEntryUpdated :Signal = new Signal(PlayerName, PlayerName);
    public var channelsChanged :Signal = new Signal(DSet, DSet);
    public var channelsEntryAdded :Signal = new Signal(ChannelEntry);
    public var channelsEntryRemoved :Signal = new Signal(ChannelEntry);
    public var channelsEntryUpdated :Signal = new Signal(ChannelEntry, ChannelEntry);
    public var locusChanged :Signal = new Signal(Locus, Locus);
    public var partyChanged :Signal = new Signal(HostedNodelet, HostedNodelet);
    public var guildNameChanged :Signal = new Signal(GuildName, GuildName);
    public var guildChanged :Signal = new Signal(HostedNodelet, HostedNodelet);

    public static const PLAYER_NAME :String = "playerName";
    public static const FRIENDS :String = "friends";
    public static const IGNORING :String = "ignoring";
    public static const IGNORED_BY :String = "ignoredBy";
    public static const CHANNELS :String = "channels";
    public static const LOCUS :String = "locus";
    public static const PARTY :String = "party";
    public static const GUILD_NAME :String = "guildName";
    public static const GUILD :String = "guild";

    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        playerName = ins.readObject(PlayerName);
        friends = ins.readObject(DSet);
        ignoring = ins.readObject(DSet);
        ignoredBy = ins.readObject(DSet);
        channels = ins.readObject(DSet);
        locus = ins.readObject(Locus);
        party = ins.readObject(HostedNodelet);
        guildName = ins.readObject(GuildName);
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
     * Returns true if at least one of the given players is a friend of ours.
     */
    public function containsOnlineFriend (playerIds :Array) :Boolean
    {
        for each (var playerId :int in playerIds) {
            if (friends.containsKey(playerId)) {
                return true;
            }
        }
        return false;
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
            case "ignoring":
                signal = _obj.ignoringChanged;
                break;
            case "ignoredBy":
                signal = _obj.ignoredByChanged;
                break;
            case "channels":
                signal = _obj.channelsChanged;
                break;
            case "locus":
                signal = _obj.locusChanged;
                break;
            case "party":
                signal = _obj.partyChanged;
                break;
            case "guildName":
                signal = _obj.guildNameChanged;
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
            case "ignoring":
                signal = _obj.ignoringEntryAdded;
                break;
            case "ignoredBy":
                signal = _obj.ignoredByEntryAdded;
                break;
            case "channels":
                signal = _obj.channelsEntryAdded;
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
            case "ignoring":
                signal = _obj.ignoringEntryRemoved;
                break;
            case "ignoredBy":
                signal = _obj.ignoredByEntryRemoved;
                break;
            case "channels":
                signal = _obj.channelsEntryRemoved;
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
            case "ignoring":
                signal = _obj.ignoringEntryUpdated;
                break;
            case "ignoredBy":
                signal = _obj.ignoredByEntryUpdated;
                break;
            case "channels":
                signal = _obj.channelsEntryUpdated;
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
