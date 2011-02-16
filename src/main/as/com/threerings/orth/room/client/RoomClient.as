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
import com.threerings.orth.world.data.WorldCredentials;

public class RoomClient extends WorldClient
{
    public function RoomClient ()
    {
        super();
    }

    override protected function buildCredentials () :Credentials
    {
        var aClient :AetherClient = inject(AetherClient);
        var aCreds :AetherCredentials = AetherCredentials(aClient.getCredentials());
        var aRsp :AetherAuthResponseData = AetherAuthResponseData(aClient.getAuthResponseData());

        return new WorldCredentials(aCreds.getUsername(), aRsp.sessionToken);
    }
}
}
