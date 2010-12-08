package com.threerings.orth.chat.client {
import com.threerings.util.Name;

import flash.geom.Point;
import flash.geom.Rectangle;

public interface ComicOverlay
{
    function didLeavePlace (roomObjectView :ChatInfoProvider):void;

    function setScrollRect ( r:Rectangle):void;

    function willEnterPlace (roomObjectView :ChatInfoProvider):void;

    function speakerMoved (username :Name, bubblePosition :Point):void;
}
}
