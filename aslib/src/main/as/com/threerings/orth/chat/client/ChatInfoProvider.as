//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.chat.client {

import flash.geom.Point;

import com.threerings.util.Name;

public interface ChatInfoProvider
{
    /**
     * Return the position to place bubbles attributed to this speaker.
     *
     * Null may be returned if the speaker is not known.
     */
    function getBubblePosition (speaker :Name) :Point;

    /**
     * Register ourselves as interested in bubbling speakers moving about.
     */
    function addBubbleObserver (observer :SpeakerObserver) :void;

    /**
     * We retract our interest in bubbling speakers moving about.
     */
    function removeBubbleObserver (observer :SpeakerObserver) :void;
}
}
