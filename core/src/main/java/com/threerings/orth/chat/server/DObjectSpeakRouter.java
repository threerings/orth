//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.chat.server;

import java.util.Set;

import com.samskivert.util.ResultListener;

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

    @Override public void sendSpeak (Speak speak, ResultListener<Set<Integer>> listener)
    {
        _dobj.postMessage(OrthChatCodes.SPEAK_MSG_TYPE, speak);
        listener.requestCompleted(getSpeakReceipients());
    }

    /**
     * Return the numerical ids of all the players that would currently receive a dispatched speak.
     */
    abstract protected Set<Integer> getSpeakReceipients ();

    protected DObject _dobj;
}
