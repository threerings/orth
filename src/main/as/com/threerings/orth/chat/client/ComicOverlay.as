/**
 * Created by ${PRODUCT_NAME}.
 * User: zell
 * Date: 3/25/11
 * Time: 10:22 AM
 * To change this template use File | Settings | File Templates.
 */
package com.threerings.orth.chat.client {

import flash.display.Graphics;
import flash.geom.Rectangle;

import com.threerings.orth.client.LayeredContainer;

public interface ComicOverlay extends ChatOverlay, OccupantChatOverlay
{
    function initComicOverlay (target :LayeredContainer) :void;

    function willEnterPlace (provider :ChatInfoProvider) :void;

    function didLeavePlace (provider :ChatInfoProvider) :void;

    function setPlaceSize (unscaledWidth :Number, unscaledHeight :Number) :void;

    /**
     * Scrolls the scrollable glyphs by applying a scroll rect to the sprite that they are on.
     */
    function setScrollRect (rect :Rectangle) :void;

    /**
     * Draw the specified bubble shape.
     *
     * @return the padding that should be applied to the bubble's label.
     */
    function drawBubbleShape (g :Graphics, type :int, txtWidth :int, txtHeight :int, tail :Boolean) :int;
}
}
