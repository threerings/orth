//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.data;

import com.google.gwt.user.client.rpc.SerializationException;
import com.google.gwt.user.client.rpc.SerializationStreamReader;
import com.google.gwt.user.client.rpc.SerializationStreamWriter;

/**
 * Custom field serializer for {@link OrthName}.
 */
public final class OrthName_CustomFieldSerializer
{
    public static void serialize (SerializationStreamWriter streamWriter, OrthName name)
        throws SerializationException
    {
        streamWriter.writeString(name.toString());
        streamWriter.writeInt(name.getId());
    }

    public static OrthName instantiate (SerializationStreamReader streamReader)
        throws SerializationException
    {
        return new OrthName(streamReader.readString(), streamReader.readInt());
    }

    public static void deserialize (SerializationStreamReader streamReader, OrthName instance)
    {
    }
}
