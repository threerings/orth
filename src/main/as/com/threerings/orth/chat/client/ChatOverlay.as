package com.threerings.orth.chat.client
{
public interface ChatOverlay
{
    function setClickableGlyphs (boolean: Boolean):void;

    function hasClickableGlyphsAtPoint (stageX :Number, stageY :Number): Boolean;
}
}
