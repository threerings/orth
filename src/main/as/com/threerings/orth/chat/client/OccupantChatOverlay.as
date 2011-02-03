package com.threerings.orth.chat.client {

import flash.geom.Point;

import com.threerings.util.Name;

public interface OccupantChatOverlay
{
    function speakerMoved (speaker:Name, pos:Point):void;
}
}
