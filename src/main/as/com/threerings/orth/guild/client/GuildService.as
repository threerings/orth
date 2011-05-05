//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.guild.client {

import com.threerings.presents.client.InvocationService;
import com.threerings.presents.client.InvocationService_InvocationListener;

import com.threerings.orth.guild.data.GuildRank;

/**
 * An ActionScript version of the Java GuildService interface.
 */
public interface GuildService extends InvocationService
{
    // from Java interface GuildService
    function disband (arg1 :InvocationService_InvocationListener) :void;

    // from Java interface GuildService
    function leave (arg1 :InvocationService_InvocationListener) :void;

    // from Java interface GuildService
    function remove (arg1 :int, arg2 :InvocationService_InvocationListener) :void;

    // from Java interface GuildService
    function sendInvite (arg1 :int, arg2 :InvocationService_InvocationListener) :void;

    // from Java interface GuildService
    function updateRank (arg1 :int, arg2 :GuildRank, arg3 :InvocationService_InvocationListener) :void;
}
}
