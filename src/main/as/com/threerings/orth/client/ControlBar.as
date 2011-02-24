//
// $Id: ControlBar.as 19594 2010-11-19 16:47:28Z zell $

package com.threerings.orth.client {

import flash.display.Sprite;

/**
 * The control bar: the main menu and global UI element across the application
 */
public interface ControlBar
{
    /** Return a casted version of yourself for convenience. */
    function asSprite () :Sprite;

    /** Return the number of pixels the bar needs to take up. */
    function getBarHeight () :Number;
}
}
