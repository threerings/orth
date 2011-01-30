//
// $Id: $

package com.threerings.orth.notify.client {

import com.threerings.orth.notify.data.Notification;

import mx.core.IUIComponent;

/** Specifies the requireents on any widget that wants to be able to display notifications. */
public interface NotificationDisplay extends IUIComponent
{
    function clearDisplay () :void;

    function displayNotification (notification :Notification) :void;

    function sizeDidChange () :void;
}
}
