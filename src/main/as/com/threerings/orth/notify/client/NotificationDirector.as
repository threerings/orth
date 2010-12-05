//
// $Id: NotificationDirector.as 19250 2010-06-25 15:15:17Z zell $

package com.threerings.orth.notify.client {

import com.threerings.crowd.client.CrowdClient;
import com.threerings.util.Name;
import com.threerings.util.Set;
import com.threerings.util.Sets;

import com.threerings.presents.client.BasicDirector;
import com.threerings.presents.client.Client;
import com.threerings.presents.client.ClientEvent;
import com.threerings.presents.client.ClientAdapter;
import com.threerings.presents.util.PresentsContext;

import com.threerings.presents.dobj.MessageEvent;
import com.threerings.presents.dobj.MessageListener;

import com.threerings.orth.notify.data.Notification;
import com.threerings.orth.notify.data.GenericNotification;

public class NotificationDirector extends BasicDirector
    implements MessageListener
{
    public function NotificationDirector (ctx :PresentsContext, notificationName :String)
    {
        super(ctx);

        _notificationName = notificationName;

        // clear our display if we lose connection to the server
        ctx.getClient().addClientObserver(new ClientAdapter(null, null, null, null, null,
            clearNotifications, null, null));
    }

    public function addGenericNotification (
        announcement :String, category :int, sender :Name = null, clickTracker :Function = null) :void
    {
        var gn :GenericNotification = new GenericNotification(announcement, category, sender);
        gn.clickTracker = clickTracker;
        addNotification(gn);
    }

    public function addNotification (notification :Notification) :void
    {
        const sender :Name = notification.getSender();
        if (sender != null && isMuted(sender)) {
            // we have muted this sender: do not notify.
            return;
        }

        // we can't just store the notifications in the array, because some notifications may be
        // identical (bob invites you to play captions twice within 15 minutes);
        _notifications.add(notification);
        getDisplay().displayNotification(notification);
    }

    public function getCurrentNotifications () :Array
    {
        return _notifications.toArray();
    }

    // from interface MessageListener
    public function messageReceived (event :MessageEvent) :void
    {
        var name :String = event.getName();
        if (name == _notificationName) {
            var notification :Notification = event.getArgs()[0] as Notification;
            if (notification != null) {
                addNotification(notification);
            }
        }
    }

    // from BasicDirector
    override public function clientDidLogoff (event :ClientEvent) :void
    {
        super.clientDidLogoff(event);

        if (!event.isSwitchingServers()) {
            clearNotifications();
        }
    }

    /** Return the NotificationDisplay implementation that will actually show the player their notifications. */
    protected function getDisplay () :NotificationDisplay
    {
        throw new Error("abstract");
    }

    /** Perform the service call to the server to release the deferred notifications. */
    protected function dispatchDeferredNotifications () :void
    {
        throw new Error("abstract");
    }

    /** Return the name of the NOTIFICATION field, i.e. *Object.NOTIFICATION. */

    /** Informs us whether or not this player never wants to hear from the given player again. */
    protected function isMuted (sender :Name) :Boolean
    {
        // override in subclasses
        return false;
    }

    // from BasicDirector
    override protected function clientObjectUpdated (client :Client) :void
    {
        super.clientObjectUpdated(client);
        (client as CrowdClient).bodyOf().addListener(this);

        // and, let's always update the control bar button
        if (!_didStartupNotifs) {
            _didStartupNotifs = true;
            showStartupNotifications();
        }

        dispatchDeferredNotifications();
    }

    protected function clearNotifications (... ignored) :void
    {
        _notifications.clear();
        getDisplay().clearDisplay();
    }

    /**
     * Called once the user is logged on and the chat system is ready.
     * Display any notifications that we generate by inspecting the user object,
     * or external data, or whatever.
     */
    protected function showStartupNotifications () :void
    {
        // nothing here, subclasses should go wild
    }

    /** Give notifications 15 minutes to be relevant. */
    protected static const NOTIFICATION_EXPIRE_TIME :int = 15 * 60 * 1000; // 15 minutes

    /** An Expiring Set to hold our most recent notifications. */
    protected var _notifications :Set = Sets.newBuilder(Notification)
        .makeExpiring(NOTIFICATION_EXPIRE_TIME).build();

    /** The name of the incoming notification messages. */
    protected var _notificationName :String;

    protected var _didStartupNotifs :Boolean;
}
}
