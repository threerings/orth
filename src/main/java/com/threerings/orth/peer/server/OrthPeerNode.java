//
// $Id: OrthPeerNode.java 17327 2009-06-22 22:04:29Z mdb $

package com.threerings.orth.peer.server;

import com.google.inject.Inject;

import com.threerings.presents.dobj.DSet;
import com.threerings.presents.dobj.EntryAddedEvent;
import com.threerings.presents.dobj.EntryRemovedEvent;
import com.threerings.presents.dobj.EntryUpdatedEvent;

import com.threerings.presents.peer.server.PeerNode;

import com.threerings.orth.party.data.PartyInfo;
import com.threerings.orth.party.data.MemberParty;
import com.threerings.orth.peer.data.OrthNodeObject;

/**
 * Handles Orth-specific peer bits.
 */
public class OrthPeerNode extends PeerNode
{
    @Override // from PeerNode
    protected NodeObjectListener createListener ()
    {
        return new OrthNodeObjectListener();
    }

    /**
     * Extends the base NodeListener with Orth-specific bits.
     */
    protected class OrthNodeObjectListener extends NodeObjectListener
    {
        @Override public void entryAdded (EntryAddedEvent<DSet.Entry> event) {
            super.entryAdded(event);
            String name = event.getName();

            if (OrthNodeObject.MEMBER_PARTIES.equals(name)) {
                MemberParty memParty = (MemberParty) event.getEntry();
// ORTH TODO
//                _partyReg.updateUserParty(
                    memParty.memberId, memParty.partyId, (OrthNodeObject)nodeobj);
            }
        }

        @Override public void entryUpdated (EntryUpdatedEvent<DSet.Entry> event) {
            super.entryUpdated(event);
            String name = event.getName();

            if (OrthNodeObject.MEMBER_PARTIES.equals(name)) {
                MemberParty memParty = (MemberParty) event.getEntry();
// ORTH TODO
//                _partyReg.updateUserParty(
//                    memParty.memberId, memParty.partyId, (OrthNodeObject)nodeobj);

            } else if (OrthNodeObject.PARTY_INFOS.equals(name)) {
// ORTH TODO
//                _partyReg.partyInfoChanged(
//                    (PartyInfo)event.getOldEntry(), (PartyInfo)event.getEntry());
            }
        }

        @Override public void entryRemoved (EntryRemovedEvent<DSet.Entry> event) {
            super.entryRemoved(event);
            String name = event.getName();

            if (OrthNodeObject.MEMBER_PARTIES.equals(name)) {
// ORTH TODO
//                _partyReg.updateUserParty((Integer)event.getKey(), 0, (OrthNodeObject)nodeobj);
            }
        }
    } // END: class OrthNodeObjectListener

    // our dependencies
//    @Inject protected PartyRegistry _partyReg;
}
