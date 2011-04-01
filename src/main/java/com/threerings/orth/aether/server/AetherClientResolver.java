//
// $Id$

package com.threerings.orth.aether.server;

import com.google.common.base.Preconditions;
import com.google.common.collect.Sets;
import com.google.inject.Inject;

import com.threerings.crowd.server.CrowdClientResolver;
import com.threerings.orth.aether.data.PlayerObject;
import com.threerings.orth.aether.server.persist.RelationshipRepository;
import com.threerings.orth.data.AuthName;
import com.threerings.orth.server.persist.OrthPlayerRecord;
import com.threerings.orth.server.persist.OrthPlayerRepository;
import com.threerings.presents.data.ClientObject;

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
    }

    protected OrthPlayerRecord _playerRec;

    // dependencies
    @Inject protected OrthPlayerRepository _playerRepo;
    @Inject protected RelationshipRepository _friendRepo;
}
