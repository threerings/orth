//
// $Id$

package com.threerings.orth.chat.client {

import flash.geom.Rectangle;

public interface ComicOverlay extends ChatOverlay, OccupantChatOverlay
{
    // TODO: Add enter/exit observers to {@link LocusDirector}
    function willEnterPlace (provider :ChatInfoProvider) :void;

    // TODO: Add enter/exit observers to {@link LocusDirector}
    function didLeavePlace (provider :ChatInfoProvider) :void;

    /**
     * Scrolls the scrollable glyphs by applying a scroll rect to the sprite that they are on.
     */
    function setScrollRect (rect :Rectangle) :void;
}
}
