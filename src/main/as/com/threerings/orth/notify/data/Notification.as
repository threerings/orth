//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.notify.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;
import com.threerings.io.SimpleStreamableObject;

import com.threerings.util.Name;

// GENERATED PREAMBLE END

/**
 * Notification from the server to the client.  Notifications are sent as messages on the
 * MemberObject.
 */
// GENERATED CLASSDECL START
public class Notification extends SimpleStreamableObject
{
// GENERATED CLASSDECL END
    // TODO: these are just placeholder categories. These will expand and users will
    // be able to customize a filtering level.
    public static const SYSTEM :int = 0;
    public static const INVITE :int = 1;
    public static const PERSONAL :int = 2;
    public static const BUTTSCRATCHING :int = 3; // your friends doing things
    public static const LOWEST :int = 4; // people coming and going, other incidentals

// GENERATED STREAMING START
    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
    }

// GENERATED STREAMING END

    /** Called if the notification is clicked, client-side only. Note that this should
     * NOT execute the primary action of the notification, this is just called if any part of it
     * is clicked */
    public var clickTracker :Function;

    /**
     * Get the chat message used to announce this notification, or null.
     * WTF are you doing with a null announcement?
     *
     * All announcements will be translated using the "notify" bundle.
     * You can qualify the string if you want a different bundle.
     */
    public function getAnnouncement () :String
    {
        throw new Error("Abstract");
    }

    /**
     * Get the category of the notification.
     */
    public function getCategory () :int
    {
        return BUTTSCRATCHING;
    }

    /**
     * Get the minimum display time for this notification, in seconds.
     */
    public function getMinDisplayTime () :int
    {
        switch (getCategory()) {
        case SYSTEM:
        case INVITE:
            return 5;

        default:
            return 2;

        case LOWEST:
            return 1;
        }
    }

    /**
     * Get the maximum display time for this notification, in seconds.
     */
    public function getMaxDisplayTime () :int
    {
        switch (getCategory()) {
        case SYSTEM: // fall through to invite
        case INVITE:
            return 2 * 60; // 2 minutes

        default:
            return 60;

        case BUTTSCRATCHING:
            return 30;

        case LOWEST:
            return 10;
        }
    }

    /**
     * Get the username of the person who sent/triggered this notification, or null
     * if this notification is not associated with another user.
     */
    public function getSender () :Name
    {
        return null;
    }

    /**
     * Get the special notification display to use for this notification, or
     * return null to just use the standard widget.
     */
    public function getDisplayClass () :String
    {
        return null;
    }

// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END
