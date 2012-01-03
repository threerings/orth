//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.data;

import com.google.gwt.user.client.rpc.SerializationException;
import com.google.gwt.user.client.rpc.SerializationStreamReader;
import com.google.gwt.user.client.rpc.SerializationStreamWriter;

/**
 * Custom field serializer for {@link PlayerName}.
 */
public final class OrthName_CustomFieldSerializer
{
    public static void serialize (SerializationStreamWriter streamWriter, PlayerName name)
        throws SerializationException
    {
        streamWriter.writeString(name.toString());
        streamWriter.writeInt(name.getId());
    }

    public static PlayerName instantiate (SerializationStreamReader streamReader)
        throws SerializationException
    {
        return new PlayerName(streamReader.readString(), streamReader.readInt());
    }

    public static void deserialize (SerializationStreamReader streamReader, PlayerName instance)
    {
    }
}
