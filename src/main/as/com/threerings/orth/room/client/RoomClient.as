//
// $Id: $
package com.threerings.orth.room.client
{
import flashx.funk.ioc.inject;

import com.threerings.presents.net.Credentials;

import com.threerings.orth.aether.client.AetherClient;
import com.threerings.orth.aether.data.AetherAuthResponseData;
import com.threerings.orth.aether.data.AetherCredentials;

import com.threerings.orth.world.client.WorldClient;

import com.threerings.orth.room.data.RoomAuthName;
import com.threerings.orth.room.data.RoomCredentials;

public class RoomClient extends WorldClient
{
    // reference classes that would otherwise not be linked in
    RoomAuthName;

    public function RoomClient ()
    {
        super();
    }

    override protected function buildCredentials () :Credentials
    {
        var aCreds :AetherCredentials = AetherCredentials(_aClient.getCredentials());
        var aRsp :AetherAuthResponseData = AetherAuthResponseData(_aClient.getAuthResponseData());

        return new RoomCredentials(aCreds.getUsername().toString(), aRsp.sessionToken);
    }

    // this is the *aether* client
    protected const _aClient :AetherClient = inject(AetherClient);
}
}
