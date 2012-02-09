//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.guild.client
{
import flashx.funk.ioc.Module;
import flashx.funk.ioc.inject;

import com.threerings.util.Log;

import com.threerings.presents.dobj.AttributeChangeListener;
import com.threerings.presents.dobj.AttributeChangedEvent;
import com.threerings.presents.dobj.DObject;

import com.threerings.orth.aether.client.AetherClient;
import com.threerings.orth.aether.data.AetherClientObject;
import com.threerings.orth.aether.data.GuildMemberNotificationComm;
import com.threerings.orth.client.Listeners;
import com.threerings.orth.comms.client.CommsDirector;
import com.threerings.orth.guild.data.GuildInviteNotification;
import com.threerings.orth.guild.data.GuildMemberEntry;
import com.threerings.orth.guild.data.GuildNodelet;
import com.threerings.orth.guild.data.GuildObject;
import com.threerings.orth.guild.data.GuildRank;
import com.threerings.orth.nodelet.client.NodeletDirector;

import org.osflash.signals.Signal;

/**
 * Connects to a player's guild on the server and provides convenient entry points and utilities
 * for a player to interact with the guild object.
 */
public class GuildDirector extends NodeletDirector
    implements AttributeChangeListener
{
    GuildNodelet;
    GuildInviteNotification;

    /**
     * A signal dispatched when our GuildObject changes; null for when we leave a guild,
     * non-null for when we join one or when we log in for the first time.
     */
    public const guildObjectChanged :Signal = new Signal(GuildObject);

    /**
     * Creates a new guild director.
     */
    public function GuildDirector()
    {
    }

    public function getGuildObject () :GuildObject
    {
        return _guildObj;
    }

    /**
     * Is the given player a member of our guild?
     */
    public function isMember (playerId :int) :Boolean
    {
        return getRank(playerId) != null;
    }

    /**
     * Is the given player a member of our guild with sufficient rank to invite others?
     */
    public function canInvite (playerId :int) :Boolean
    {
        return getRank(playerId) == GuildRank.OFFICER;
    }

    /**
     * Return the guild rank of the given player, or null if not a member of our guild.
     */
    public function getRank (playerId :int) :GuildRank
    {
        var entry :GuildMemberEntry = null;
        if (_guildObj != null) {
            entry = GuildMemberEntry(_guildObj.members.get(playerId));
        }
        return (entry != null) ? entry.rank : null;
    }

    /**
     * Called when a player attribute is updated.
     */
    public function attributeChanged (event :AttributeChangedEvent) :void
    {
        if (event.getName() == AetherClientObject.GUILD) {
            // connect to the guild
            connect(_plobj.guild);
        }
    }

    public function invite (playerId :int) :void
    {
        if (_guildObj == null) {
            log.warning("Weird, inviting someone to non-guild?");
            return;
        }
        _guildObj.guildService.sendInvite(playerId, Listeners.listener());
    }

    public function leave () :void
    {
        _guildObj.guildService.leave(Listeners.listener());
    }

    public function disband () :void
    {
        _guildObj.guildService.disband(Listeners.listener());
    }

    public function remove (playerId :int) :void
    {
        _guildObj.guildService.remove(playerId, Listeners.listener());
    }

    public function setRank (playerId :int, rank :GuildRank) :void
    {
        _guildObj.guildService.updateRank(playerId, rank, Listeners.listener());
    }

    override protected function disconnect () :void
    {
        super.disconnect();

        guildObjectChanged.dispatch(null);
    }

// from NodeletDirector
    override protected function refreshPlayer () :void
    {
        if (_plobj != null) {
            _plobj.removeListener(this);
            _plobj = null;
        }

        super.refreshPlayer();

        if (_plobj != null) {
            _plobj.addListener(this);
            connect(_plobj.guild);
        } else {
            disconnect();
        }
    }

    // from NodeletDirector
    override protected function objectAvailable (obj :DObject) :void
    {
        super.objectAvailable(obj);
        _guildObj = GuildObject(obj);
        if (_guildObj != null) {
            _guildObj.membersEntryAdded.add(memberAdded);
            _guildObj.membersEntryRemoved.add(memberRemoved);
            _guildObj.membersEntryUpdated.add(memberUpdated);
        }

        guildObjectChanged.dispatch(_guildObj);
    }

    protected function memberAdded (entry :GuildMemberEntry) :void
    {
        if (entry.name.id == _octx.myId) {
            // the server should already have added us prior to subscription
            log.warning("Local player added to guild, weird");
        } else {
            notify(entry, GuildMemberNotificationComm.NOTE_JOIN);
        }
    }

    protected function memberRemoved (entry :GuildMemberEntry) :void
    {
        if (entry.name.id == _octx.myId) {
            log.warning("Local player removed from guild, weird");
        } else {
            notify(entry, GuildMemberNotificationComm.NOTE_LEAVE);
        }
    }

    protected function memberUpdated (entry :GuildMemberEntry, old :GuildMemberEntry) :void
    {
        if (entry.name.id == _octx.myId) {
            if (old.rank != entry.rank) {
                localPlayerRankChanged();
            }
        } else if (old.whereabouts.isOnline() != entry.whereabouts.isOnline()) {
            notify(entry, entry.whereabouts.isOnline() ?
                GuildMemberNotificationComm.NOTE_LOGON : GuildMemberNotificationComm.NOTE_LOGOFF);
        }
    }

    protected function notify (entry :GuildMemberEntry, event :int) :void
    {
        _commsDir.receiveComm(new GuildMemberNotificationComm(
            entry.name, _client.playerName, event));
    }

    protected function localPlayerRankChanged () :void
    {
        // UI will have something to do here
    }

    protected var _guildObj :GuildObject;

    protected const _module :Module = inject(Module);
    protected const _client :AetherClient = inject(AetherClient);
    protected const _commsDir :CommsDirector = inject(CommsDirector);

    private const log :Log = Log.getLog(this);
}
}
