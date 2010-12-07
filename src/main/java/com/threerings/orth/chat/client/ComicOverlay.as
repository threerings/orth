package com.threerings.orth.chat.client
{
import flash.geom.Rectangle;

public interface ComicOverlay
{
    function didLeavePlace (roomObjectView :ChatInfoProvider):void;

    function setScrollRect (r:Rectangle):void;

    function willEnterPlace (roomObjectView :ChatInfoProvider):void;
}
}
