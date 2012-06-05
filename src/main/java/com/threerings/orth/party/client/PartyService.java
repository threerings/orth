//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.party.client;

import com.threerings.presents.client.InvocationService;

import com.threerings.orth.data.PlayerName;
import com.threerings.orth.locus.data.HostedLocus;
import com.threerings.orth.party.data.PartierObject;
import com.threerings.orth.party.data.PartyPolicy;

/**
 * Provides services to people in a party.
 */
public interface PartyService extends InvocationService<PartierObject>
{
    /** Requests our departure from this party. */
    void leaveParty (InvocationListener il);

    /** Requests to boot a player from the party. */
    void bootPlayer (int playerId, InvocationListener il);

    /** Requests to reassign leadership to another player. */
    void assignLeader (int playerId, InvocationListener il);

    /** Requests to update the party status. */
    void updateStatus (String status, InvocationListener il);

    /** Requests to change the party access control. */
    void updatePolicy (PartyPolicy policy, InvocationListener il);

    /** Requests to change the disband setting. */
    void updateDisband (boolean disband, InvocationListener il);

    /** Invites a specific player to this party. */
    void invitePlayer (PlayerName invitee, InvocationListener il);

    /** Moves the entire party to the given locus. Move to null to let partiers roam freely. */
    void moveParty (HostedLocus locus, InvocationListener il);
}
