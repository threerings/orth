package com.threerings.orth.room.server;

import com.google.inject.Inject;

import com.threerings.presents.net.BootstrapData;
import com.threerings.presents.server.PresentsSession;

public class RoomSession extends PresentsSession
{
    @Override
    protected void sessionConnectionClosed ()
    {
        super.sessionConnectionClosed();
    }

    @Override
    protected void populateBootstrapData (BootstrapData data)
    {
        super.populateBootstrapData(data);
    }
}
