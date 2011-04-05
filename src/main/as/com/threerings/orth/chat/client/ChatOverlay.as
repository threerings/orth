package com.threerings.orth.chat.client {

import com.threerings.crowd.chat.client.ChatDisplay;

import com.threerings.orth.client.LayeredContainer;

public interface ChatOverlay extends ChatDisplay
{
    function initOverlay (target :LayeredContainer) :void;
}
}
