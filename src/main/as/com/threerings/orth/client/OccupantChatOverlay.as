package com.threerings.orth.client
{
import com.threerings.util.Name;

import flash.geom.Point;

public interface OccupantChatOverlay
{
    function speakerMoved (speaker:Name, pos:Point):void;
}
}
