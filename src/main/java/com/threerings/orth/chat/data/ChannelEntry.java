//
// Who - Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.chat.data;

import com.threerings.io.SimpleStreamableObject;

import com.threerings.presents.dobj.DSet.Entry;

public class ChannelEntry extends SimpleStreamableObject
    implements Entry
{
    public String channelId;
    public SpeakMarshaller speakService;

    public ChannelEntry (String channelId, SpeakMarshaller speakService)
    {
        this.channelId = channelId;
        this.speakService = speakService;
    }

    @Override public Comparable<?> getKey ()
    {
        return channelId;
    }
}
