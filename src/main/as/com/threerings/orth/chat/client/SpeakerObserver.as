//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.chat.client {

import flash.geom.Point;

import com.threerings.util.Name;

public interface SpeakerObserver
{
    function speakerMoved (speaker :Name, pos :Point) :void;
}
}
