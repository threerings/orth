//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

// GENERATED PREAMBLE START
package com.threerings.orth.chat.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;
import com.threerings.io.SimpleStreamableObject;

import com.threerings.presents.dobj.DSet_Entry;

import com.threerings.orth.chat.data.SpeakMarshaller;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class ChannelEntry extends SimpleStreamableObject
    implements DSet_Entry
{
// GENERATED CLASSDECL END

    public function getKey () :Object
    {
        return channelId;
    }

// GENERATED STREAMING START
    public var channelId :String;

    public var title :String;

    public var speakService :SpeakMarshaller;

    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        channelId = ins.readField(String);
        title = ins.readField(String);
        speakService = ins.readObject(SpeakMarshaller);
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeField(channelId);
        out.writeField(title);
        out.writeObject(speakService);
    }

// GENERATED STREAMING END

// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END

