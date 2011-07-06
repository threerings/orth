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

import com.threerings.orth.aether.data.AetherClientObject;
import com.threerings.orth.aether.server.persist.RelationshipRepository;
import com.threerings.orth.data.AuthName;
import com.threerings.orth.guild.data.GuildNodelet;
import com.threerings.orth.guild.server.GuildRegistry;
import com.threerings.orth.guild.server.persist.GuildRepository;
import com.threerings.orth.nodelet.data.HostedNodelet;
import com.threerings.orth.server.persist.PlayerRecord;
import com.threerings.orth.server.persist.PlayerRepository;

import static com.threerings.orth.Log.log;

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
    {
        int playerId = ((AuthName)_username).getId();

        // load up their player information using on their authentication (account) name
        _playerRec = Preconditions.checkNotNull(_playerRepo.loadPlayer(playerId),
            "Missing player record for authenticated player? [username=%s]", _username);

        // load the friend ids, these will get fully resolved later
        plobj.getLocal(AetherLocal.class).unresolvedFriendIds = Sets.newHashSet(
            _friendRepo.getFriendIds(playerId));

        // set the guild id
        plobj.guildId = _guildRepo.getGuildId(playerId);
    }

    @Override // from ClientResolver
    protected void finishResolution (ClientObject clobj)
    {
        super.finishResolution(clobj);

        final AetherClientObject plobj = (AetherClientObject)clobj;
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

    protected PlayerRecord _playerRec;

    // dependencies
    @Inject protected PlayerRepository _playerRepo;
    @Inject protected RelationshipRepository _friendRepo;
    @Inject protected GuildRegistry _guildReg;
    @Inject protected GuildRepository _guildRepo;
}
