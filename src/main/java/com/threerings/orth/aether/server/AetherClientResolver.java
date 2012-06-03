//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.aether.server;

import com.google.common.base.Preconditions;
import com.google.common.collect.Sets;
import com.google.inject.Inject;

import com.threerings.presents.data.ClientObject;
import com.threerings.presents.dobj.DSet;

import com.threerings.crowd.server.CrowdClientResolver;

import com.threerings.orth.aether.data.AetherClientObject;
import com.threerings.orth.aether.server.persist.RelationshipRepository;
import com.threerings.orth.data.AuthName;
import com.threerings.orth.guild.server.GuildRegistry;
import com.threerings.orth.guild.server.persist.GuildRepository;
import com.threerings.orth.server.persist.PlayerRecord;
import com.threerings.orth.server.persist.PlayerRepository;

/**
 * Performs resolution of aether clients.
 */
public class AetherClientResolver extends CrowdClientResolver
{
    @Override // from ClientResolver
    public AetherClientObject createClientObject ()
    {
        return new AetherClientObject();
    }

    @Override // from ClientResolver
    public AetherLocal createLocalAttribute ()
    {
        return new AetherLocal();
    }

    @Override // from ClientResolver
    protected void resolveClientData (ClientObject clobj)
        throws Exception
    {
        super.resolveClientData(clobj);
        clobj.getLocal(AetherLocal.class).init();
        resolvePlayer((AetherClientObject)clobj);
    }

    /**
     * Resolves the members for an aether player. This is called on the invoker thread.
     */
    protected void resolvePlayer (final AetherClientObject plobj)
        throws Exception
    {
        int playerId = ((AuthName)_username).getId();

        // load up their player information using on their authentication (account) name
        _playerRec = Preconditions.checkNotNull(_playerRepo.loadPlayer(playerId),
            "Missing player record for authenticated player? [username=%s]", _username);

        // load the friend ids, these will get fully resolved later
        final AetherLocal local = plobj.getLocal(AetherLocal.class);
        local.unresolvedFriendIds = Sets.newHashSet(_relationRepo.getFriendIds(playerId));

        // resolve the ignore list
        plobj.ignoring = DSet.newDSet(_ignoreMgr.resolveIgnoreList(playerId));

        // set the guild id
        plobj.guildName = _guildRepo.getGuildName(playerId);
    }

    @Override // from ClientResolver
    protected void finishResolution (ClientObject clobj)
    {
        super.finishResolution(clobj);

        final AetherClientObject plobj = (AetherClientObject)clobj;
        if (plobj.guildName != null) {
            _guildReg.resolveGuild(plobj, plobj.guildName.getGuildId());
        }
    }

    protected PlayerRecord _playerRec;

    // dependencies
    @Inject protected PlayerRepository _playerRepo;
    @Inject protected RelationshipRepository _relationRepo;
    @Inject protected IgnoreManager _ignoreMgr;
    @Inject protected GuildRegistry _guildReg;
    @Inject protected GuildRepository _guildRepo;
}
