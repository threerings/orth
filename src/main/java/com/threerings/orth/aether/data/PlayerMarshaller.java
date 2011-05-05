//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.
package com.threerings.orth.aether.data;

import javax.annotation.Generated;

import com.threerings.orth.aether.client.PlayerService;
import com.threerings.presents.client.InvocationService;
import com.threerings.presents.data.InvocationMarshaller;

/**
 * Provides the implementation of the {@link PlayerService} interface
 * that marshalls the arguments and delivers the request to the provider
 * on the server. Also provides an implementation of the response listener
 * interfaces that marshall the response arguments and deliver them back
 * to the requesting client.
 */
@Generated(value={"com.threerings.presents.tools.GenServiceTask"},
           comments="Derived from PlayerService.java.")
public class PlayerMarshaller extends InvocationMarshaller
    implements PlayerService
{
    /** The method id used to dispatch {@link #acceptGuildInvite} requests. */
    public static final int ACCEPT_GUILD_INVITE = 1;

    // from interface PlayerService
    public void acceptGuildInvite (int arg1, int arg2, InvocationService.InvocationListener arg3)
    {
        ListenerMarshaller listener3 = new ListenerMarshaller();
        listener3.listener = arg3;
        sendRequest(ACCEPT_GUILD_INVITE, new Object[] {
            Integer.valueOf(arg1), Integer.valueOf(arg2), listener3
        });
    }

    /** The method id used to dispatch {@link #createGuild} requests. */
    public static final int CREATE_GUILD = 2;

    // from interface PlayerService
    public void createGuild (String arg1, InvocationService.InvocationListener arg2)
    {
        ListenerMarshaller listener2 = new ListenerMarshaller();
        listener2.listener = arg2;
        sendRequest(CREATE_GUILD, new Object[] {
            arg1, listener2
        });
    }

    /** The method id used to dispatch {@link #dispatchDeferredNotifications} requests. */
    public static final int DISPATCH_DEFERRED_NOTIFICATIONS = 3;

    // from interface PlayerService
    public void dispatchDeferredNotifications ()
    {
        sendRequest(DISPATCH_DEFERRED_NOTIFICATIONS, new Object[] {
        });
    }

    /** The method id used to dispatch {@link #ditchFollower} requests. */
    public static final int DITCH_FOLLOWER = 4;

    // from interface PlayerService
    public void ditchFollower (int arg1, InvocationService.InvocationListener arg2)
    {
        ListenerMarshaller listener2 = new ListenerMarshaller();
        listener2.listener = arg2;
        sendRequest(DITCH_FOLLOWER, new Object[] {
            Integer.valueOf(arg1), listener2
        });
    }

    /** The method id used to dispatch {@link #followPlayer} requests. */
    public static final int FOLLOW_PLAYER = 5;

    // from interface PlayerService
    public void followPlayer (int arg1, InvocationService.InvocationListener arg2)
    {
        ListenerMarshaller listener2 = new ListenerMarshaller();
        listener2.listener = arg2;
        sendRequest(FOLLOW_PLAYER, new Object[] {
            Integer.valueOf(arg1), listener2
        });
    }

    /** The method id used to dispatch {@link #inviteToFollow} requests. */
    public static final int INVITE_TO_FOLLOW = 6;

    // from interface PlayerService
    public void inviteToFollow (int arg1, InvocationService.InvocationListener arg2)
    {
        ListenerMarshaller listener2 = new ListenerMarshaller();
        listener2.listener = arg2;
        sendRequest(INVITE_TO_FOLLOW, new Object[] {
            Integer.valueOf(arg1), listener2
        });
    }

    /** The method id used to dispatch {@link #setAvatar} requests. */
    public static final int SET_AVATAR = 7;

    // from interface PlayerService
    public void setAvatar (int arg1, InvocationService.ConfirmListener arg2)
    {
        InvocationMarshaller.ConfirmMarshaller listener2 = new InvocationMarshaller.ConfirmMarshaller();
        listener2.listener = arg2;
        sendRequest(SET_AVATAR, new Object[] {
            Integer.valueOf(arg1), listener2
        });
    }
}
