package com.threerings.orth.guild.client
{
import flashx.funk.ioc.Module;
import flashx.funk.ioc.inject;

import com.threerings.util.Log;

import com.threerings.presents.dobj.AttributeChangeListener;
import com.threerings.presents.dobj.AttributeChangedEvent;
import com.threerings.presents.dobj.ChangeListener;
import com.threerings.presents.dobj.DObject;

import com.threerings.orth.aether.data.PlayerObject;
import com.threerings.orth.guild.data.GuildMemberEntry;
import com.threerings.orth.guild.data.GuildNodelet;
import com.threerings.orth.guild.data.GuildObject;
import com.threerings.orth.guild.data.GuildRank;
import com.threerings.orth.nodelet.client.NodeletDirector;

/**
 * Connects to a player's guild on the server and provides convenient entry points and utilities
 * for a player to interact with the guild object.
 */
public class GuildDirector extends NodeletDirector
    implements AttributeChangeListener
{
    GuildNodelet;

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
     * Called when a player attribute is updated.
     */
    public function attributeChanged (event :AttributeChangedEvent) :void
    {
        if (event.getName() == PlayerObject.GUILD) {
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
        _guildObj.guildService.sendInvite(playerId, _octx.listener());
    }

    public function leave () :void
    {
        _guildObj.guildService.leave(_octx.listener());
    }

    public function disband () :void
    {
        _guildObj.guildService.disband(_octx.listener());
    }

    public function remove (playerId :int) :void
    {
        _guildObj.guildService.remove(playerId, _octx.listener());
    }

    public function setRank (playerId :int, rank :GuildRank) :void
    {
        _guildObj.guildService.updateRank(playerId, rank, _octx.listener());
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
    }

    protected function memberAdded (entry :GuildMemberEntry) :void
    {
        if (entry.name.getId() == _octx.getMyId()) {
            // the server should already have added us prior to subscription
            log.warning("Local player added to guild, weird");
        }
    }

    protected function memberRemoved (entry :GuildMemberEntry) :void
    {
        if (entry.name.getId() == _octx.getMyId()) {
            log.warning("Local player removed from guild, weird");
        }
    }

    protected function memberUpdated (entry :GuildMemberEntry, old :GuildMemberEntry) :void
    {
        if (entry.name.getId() == _octx.getMyId()) {
            if (old.rank != entry.rank) {
                localPlayerRankChanged();
            }
        }
    }

    protected function localPlayerRankChanged () :void
    {
        // UI will have something to do here
    }

    protected var _guildObj :GuildObject;
    protected var _module :Module = inject(Module);
    private const log :Log = Log.getLog(this);
}
}
