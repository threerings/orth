//
// $Id$

package com.threerings.orth.guild.client {

import com.threerings.presents.client.InvocationService;
import com.threerings.presents.client.InvocationService_InvocationListener;

/**
 * An ActionScript version of the Java GuildService interface.
 */
public interface GuildService extends InvocationService
{
    // from Java interface GuildService
    function sendInvite (arg1 :int, arg2 :InvocationService_InvocationListener) :void;
}
}
