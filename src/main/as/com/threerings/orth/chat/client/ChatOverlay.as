//
// $Id: $

package com.threerings.orth.chat.client {

import com.threerings.crowd.chat.client.ChatDisplay;

public interface ChatOverlay
    extends ChatDisplay
{
    function displayChat (display :Boolean) :void;

    /**
     * @return true if there are clickable glyphs under the specified point.
     */
    function hasClickableGlyphsAtPoint (stageX :Number, stageY :Number) :Boolean;
}
}
