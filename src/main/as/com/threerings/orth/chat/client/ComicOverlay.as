/**
 * Created by ${PRODUCT_NAME}.
 * User: zell
 * Date: 3/25/11
 * Time: 10:22 AM
 * To change this template use File | Settings | File Templates.
 */
package com.threerings.orth.chat.client {

import flash.geom.Rectangle;

public interface ComicOverlay extends ChatOverlay, OccupantChatOverlay
{
    function willEnterPlace (provider :ChatInfoProvider) :void;

    function didLeavePlace (provider :ChatInfoProvider) :void;

    function setPlaceSize (unscaledWidth :Number, unscaledHeight :Number) :void;

    /**
     * Scrolls the scrollable glyphs by applying a scroll rect to the sprite that they are on.
     */
    function setScrollRect (rect :Rectangle) :void;
}
}
