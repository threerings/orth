//
// $Id: $

package com.threerings.orth.chat.client {

import flash.geom.Rectangle;

import com.threerings.crowd.chat.client.ChatDisplay;
import com.threerings.orth.chat.client.ChatInfoProvider;

public interface ComicOverlay
    extends ChatOverlay
{
    function willEnterPlace (provider :ChatInfoProvider) :void;
    function didLeavePlace (provider :ChatInfoProvider) :void;
    function setScrollRect (rect :Rectangle) :void;
}
}
