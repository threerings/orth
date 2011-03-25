package com.threerings.orth.chat.client {

import com.threerings.crowd.chat.client.ChatDisplay;

import com.threerings.orth.client.LayeredContainer;

public interface ChatOverlay extends ChatDisplay
{
    function initChatOverlay (target :LayeredContainer, includeOccupantList :Boolean = false) :void;

    function displayChat (display :Boolean) :void;

    /**
     * @return true if there are clickable glyphs under the specified point.
     */
    function hasClickableGlyphsAtPoint (stageX :Number, stageY :Number) :Boolean;

    /**
     * Sets whether or not the glyphs are clickable.
     */
    function setClickableGlyphs (clickable :Boolean) :void;

    /**
     * Remove a glyph from the overlay.
     */
    function removeGlyph (glyph :ChatGlyph) :void;

    /**
     * Callback from a ChatGlyph when it wants to be removed.
     */
    function glyphExpired (glyph :ChatGlyph) :void;

    function getTargetTextWidth () :int;
}
}
