// GENERATED PREAMBLE START
//
// $Id$

package com.threerings.orth.aether.data {

import org.osflash.signals.Signal;

import com.threerings.io.ObjectInputStream;

import com.threerings.presents.data.ClientObject;
import com.threerings.presents.dobj.DSet;
import com.threerings.presents.dobj.DSet_Entry;

import com.threerings.orth.aether.data.PlayerName;
import com.threerings.orth.aether.data.VizPlayerName;
import com.threerings.orth.data.PlayerEntry;
import com.threerings.orth.world.data.OrthPlace;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class PlayerObject extends ClientObject
{
// GENERATED CLASSDECL END

// GENERATED STREAMING START
    public var playerName :VizPlayerName;

    public var location :OrthPlace;

    public var following :PlayerName;

    public var followers :DSet;

    public var friends :DSet;

    public var partyId :int;

    public var playerNameChanged :Signal = new Signal(VizPlayerName, VizPlayerName);
    public var locationChanged :Signal = new Signal(OrthPlace, OrthPlace);
    public var followingChanged :Signal = new Signal(PlayerName, PlayerName);
    public var followersChanged :Signal = new Signal(DSet, DSet);
    public var followersEntryAdded :Signal = new Signal(DSet_Entry);
    public var followersEntryRemoved :Signal = new Signal(DSet_Entry);
    public var followersEntryUpdated :Signal = new Signal(DSet_Entry, DSet_Entry);
    public var friendsChanged :Signal = new Signal(DSet, DSet);
    public var friendsEntryAdded :Signal = new Signal(DSet_Entry);
    public var friendsEntryRemoved :Signal = new Signal(DSet_Entry);
    public var friendsEntryUpdated :Signal = new Signal(DSet_Entry, DSet_Entry);
    public var partyIdChanged :Signal = new Signal(int, int);

    public static const PLAYER_NAME :String = "playerName";

    public static const LOCATION :String = "location";

    public static const FOLLOWING :String = "following";

    public static const FOLLOWERS :String = "followers";

    public static const FRIENDS :String = "friends";

    public static const PARTY_ID :String = "partyId";

    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        playerName = ins.readObject(VizPlayerName);
        location = ins.readObject(OrthPlace);
        following = ins.readObject(PlayerName);
        followers = ins.readObject(DSet);
        friends = ins.readObject(DSet);
        partyId = ins.readInt();
    }

    public function PlayerObject ()
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
    public function getPlayerId () :int
    {
        return playerName.getId();
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

import com.threerings.orth.aether.data.PlayerObject;

class Signaller
    implements AttributeChangeListener, SetListener, ElementUpdateListener, OidListListener
{
    public function Signaller (obj :PlayerObject)
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
            case "location":
                signal = _obj.locationChanged;
                break;
            case "following":
                signal = _obj.followingChanged;
                break;
            case "followers":
                signal = _obj.followersChanged;
                break;
            case "friends":
                signal = _obj.friendsChanged;
                break;
            case "partyId":
                signal = _obj.partyIdChanged;
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
            case "followers":
                signal = _obj.followersEntryAdded;
                break;
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
            case "followers":
                signal = _obj.followersEntryRemoved;
                break;
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
            case "followers":
                signal = _obj.followersEntryUpdated;
                break;
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

    protected var _obj :PlayerObject;
}
// GENERATED SIGNALLER END
