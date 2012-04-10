//
// Who - Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.chat.server;

import com.threerings.presents.dobj.DObject;

import com.threerings.orth.chat.data.OrthChatCodes;
import com.threerings.orth.chat.data.Speak;
import com.threerings.orth.chat.data.SpeakRouter;

/**
 *
 */
public abstract class DObjectSpeakRouter
    implements SpeakRouter
{
    public DObjectSpeakRouter (DObject dobj)
    {
        _dobj = dobj;
    }

    @Override public void sendSpeak (Speak speak)
    {
        _dobj.postMessage(OrthChatCodes.SPEAK_MSG_TYPE, speak);
    }

    protected DObject _dobj;
}
