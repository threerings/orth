//
// $Id: ChatInfoProvider.as 14149 2008-12-31 18:13:55Z mdb $

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
}
}
