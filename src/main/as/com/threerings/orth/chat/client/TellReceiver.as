//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.chat.client {

import com.threerings.presents.client.InvocationReceiver;

import com.threerings.orth.chat.data.Tell;

public interface TellReceiver extends InvocationReceiver
{
    // from Java interface TellReceiver
    function receiveTell (arg1 :Tell) :void;
}
}
