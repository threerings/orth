//
// $Id$

package com.threerings.orth.party.client;

import com.threerings.presents.client.Client;
import com.threerings.presents.client.InvocationService;

/**
 * Provides services to people in a party.
 */
public interface PartyService extends InvocationService
{
    /** Requests to boot a player from the party. */
    void bootMember (int memberId, InvocationListener il);

    /** Requests to reassign leadership to another player. */
    void assignLeader (int memberId, InvocationListener il);

    /** Requests to update the party status. */
    void updateStatus (String status, InvocationListener il);

    /** Requests to change the party access control. */
    void updateRecruitment (byte recruitment, InvocationListener il);

    /** Requests to change the disband setting. */
    void updateDisband (boolean disband, InvocationListener il);

    /** Invites a specific player to this party. */
    void inviteMember (int memberId, InvocationListener il);

    /** Called by the leader to move the party to a new scene. */
    void moveParty (int sceneId, InvocationListener il);
}
