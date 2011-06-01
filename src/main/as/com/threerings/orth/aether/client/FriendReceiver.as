//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.aether.client {

import com.threerings.presents.client.InvocationReceiver;

import com.threerings.orth.aether.data.PlayerName;

public interface FriendReceiver extends InvocationReceiver
{
    // from Java interface FriendReceiver
    function friendshipRequested (arg1 :PlayerName) :void;
}
}
