//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.whirled {

import flash.display.DisplayObject;

/**
 * Used to create Toys: interactive furniture, usually with some shared state.
 */
public class ToyControl extends FurniControl
{
    /**
     * Create a ToyControl.
     *
     * @param disp a display object on the stage
     */
    public function ToyControl (disp :DisplayObject)
    {
        super(disp);
    }
}
}
