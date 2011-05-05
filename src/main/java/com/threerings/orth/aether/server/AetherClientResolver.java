//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.
package com.threerings.orth.aether.server;

import com.google.common.base.Preconditions;
import com.google.common.collect.Sets;
import com.google.inject.Inject;

import com.threerings.crowd.server.CrowdClientResolver;
import com.threerings.presents.data.ClientObject;
import com.threerings.util.Resulting;

import com.threerings.orth.aether.data.PlayerObject;
import com.threerings.orth.aether.server.persist.RelationshipRepository;
import com.threerings.orth.data.AuthName;
import com.threerings.orth.guild.data.GuildNodelet;
import com.threerings.orth.guild.server.GuildRegistry;
import com.threerings.orth.guild.server.persist.GuildRepository;
import com.threerings.orth.nodelet.data.HostedNodelet;
import com.threerings.orth.server.persist.OrthPlayerRecord;
import com.threerings.orth.server.persist.OrthPlayerRepository;

import static com.threerings.orth.Log.log;

/**
 * Performs resolution of aether clients.
 */
public class AetherClientResolver extends CrowdClientResolver
{
    @Override // from ClientResolver
    public PlayerObject createClientObject ()
    {
        return new PlayerObject();
    }

    @Override // from ClientResolver
    public PlayerLocal createLocalAttribute ()
    {
        return new PlayerLocal();
    }

    @Override // from ClientResolver
    protected void resolveClientData (ClientObject clobj)
        throws Exception
    {
        super.resolveClientData(clobj);
        clobj.getLocal(PlayerLocal.class).init();
        resolvePlayer((PlayerObject)clobj);
    }

    /**
     * Resolves the members for an aether player. This is called on the invoker thread.
     */
    protected void resolvePlayer (final PlayerObject plobj)
    {
        int playerId = ((AuthName)_username).getId();

        // load up their player information using on their authentication (account) name
        _playerRec = Preconditions.checkNotNull(_playerRepo.loadPlayer(playerId),
            "Missing player record for authenticated player? [username=%s]", _username);

        // load the friend ids, these will get fully resolved later
        plobj.getLocal(PlayerLocal.class).unresolvedFriendIds = Sets.newHashSet(
            _friendRepo.getFriendIds(playerId));

        // set the guild id
        plobj.guildId = _guildRepo.getGuildId(playerId);
    }

    @Override // from ClientResolver
    protected void finishResolution (ClientObject clobj)
    {
        super.finishResolution(clobj);

        final PlayerObject plobj = (PlayerObject)clobj;
        if (plobj.guildId != 0) {
            _guildReg.resolveHosting(clobj, new GuildNodelet(plobj.guildId),
                new Resulting<HostedNodelet>("HostedNodelet for guild", log,
                        "player", plobj.who(), "guildId", plobj.guildId) {
                    @Override public void requestCompleted (HostedNodelet result) {
                        plobj.setGuild(result);
                    }
            });
        }
    }

    protected OrthPlayerRecord _playerRec;

    // dependencies
    @Inject protected OrthPlayerRepository _playerRepo;
    @Inject protected RelationshipRepository _friendRepo;
    @Inject protected GuildRegistry _guildReg;
    @Inject protected GuildRepository _guildRepo;
}
