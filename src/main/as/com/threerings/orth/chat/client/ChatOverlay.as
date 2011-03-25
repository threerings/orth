package com.threerings.orth.chat.client {

import com.threerings.crowd.chat.client.ChatDisplay;

import com.threerings.orth.client.LayeredContainer;

public interface ChatOverlay extends ChatDisplay
{
    function initOverlay (target :LayeredContainer) :void;

    function displayChat (display :Boolean) :void;

    /**
     * @return true if there are clickable glyphs under the specified point.
     */
    function hasClickableGlyphsAtPoint (stageX :Number, stageY :Number) :Boolean;

    /**
     * Sets whether or not the glyphs are clickable.
     */
    function setClickableGlyphs (clickable :Boolean) :void;
}
}
