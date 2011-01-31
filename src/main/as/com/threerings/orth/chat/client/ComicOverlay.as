//
// $Id: $

package com.threerings.orth.chat.client {

import flash.geom.Rectangle;

public interface ComicOverlay
    extends ChatOverlay, OccupantChatOverlay
{
    function willEnterPlace (provider :ChatInfoProvider) :void;
    function didLeavePlace (provider :ChatInfoProvider) :void;
    function setScrollRect (rect :Rectangle) :void;

    function setClickableGlyphs (clickable :Boolean) :void;
}
}
