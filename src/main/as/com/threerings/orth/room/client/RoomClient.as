//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.room.client {
import flashx.funk.ioc.inject;

import com.threerings.presents.net.Credentials;

import com.threerings.orth.aether.client.AetherClient;
import com.threerings.orth.entity.data.AvatarData;
import com.threerings.orth.entity.data.MediaWalkability;
import com.threerings.orth.locus.client.LocusClient;
import com.threerings.orth.room.data.DecorData;
import com.threerings.orth.room.data.OrthRoomConfig;
import com.threerings.orth.room.data.RoomAuthName;
import com.threerings.orth.room.data.RoomCredentials;
import com.threerings.orth.room.data.RoomPlace;

public class RoomClient extends LocusClient
{
    // reference classes that would otherwise not be linked in
    RoomAuthName;
    RoomPlace;
    OrthRoomConfig;
    DecorData;
    AvatarData;
    MediaWalkability;

    override protected function buildCredentials () :Credentials
    {
        return new RoomCredentials(_aClient.sessionToken);
    }

    // this is the *aether* client
    protected const _aClient :AetherClient = inject(AetherClient);
}
}
