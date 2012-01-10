//
// Who - Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.peer.server;

import com.google.inject.Inject;

import com.threerings.presents.dobj.DSet.Entry;
import com.threerings.presents.dobj.EntryUpdatedEvent;
import com.threerings.presents.peer.server.PeerNode;

import com.threerings.orth.peer.data.OrthClientInfo;
import com.threerings.orth.peer.data.OrthNodeObject;

public class OrthPeerNode extends PeerNode
{
    @Override protected NodeObjectListener createListener ()
    {
        return new OrthNodeObjectListener();
    }

    protected class OrthNodeObjectListener extends NodeObjectListener
    {
        @Override public void entryUpdated (EntryUpdatedEvent<Entry> event) {
            super.entryUpdated(event);

            if (OrthNodeObject.CLIENTS.equals(event.getName())) {
                _orthpeermgr.clientInfoChanged(getNodeName(), (OrthClientInfo) event.getEntry());
            }
        }
    }

    @Inject protected OrthPeerManager _orthpeermgr;
}
