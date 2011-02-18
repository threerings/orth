//
// $Id: $
package com.threerings.orth.room.client
{
import flashx.funk.ioc.inject;

import com.threerings.presents.net.Credentials;

import com.threerings.orth.aether.client.AetherClient;
import com.threerings.orth.aether.data.AetherAuthResponseData;
import com.threerings.orth.entity.data.AvatarData;
import com.threerings.orth.entity.data.DecorData;
import com.threerings.orth.room.data.EntityData;
import com.threerings.orth.room.data.OrthRoomConfig;
import com.threerings.orth.room.data.RoomAuthName;
import com.threerings.orth.room.data.RoomCredentials;
import com.threerings.orth.world.client.WorldClient;

public class RoomClient extends WorldClient
{
    // reference classes that would otherwise not be linked in
    RoomAuthName;
    OrthRoomConfig;
    EntityData;
    DecorData;
    AvatarData;

    public function RoomClient ()
    {
        super();
    }

    override protected function buildCredentials () :Credentials
    {
        var aRsp :AetherAuthResponseData = AetherAuthResponseData(_aClient.getAuthResponseData());

        return new RoomCredentials(aRsp.sessionToken);
    }

    // this is the *aether* client
    protected const _aClient :AetherClient = inject(AetherClient);
}
}
