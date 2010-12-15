//
// $Id: BlankPlaceView.as 19691 2010-12-01 03:48:23Z zell $

package com.threerings.orth.world.client {
import com.threerings.orth.client.Msgs;
import com.threerings.orth.client.OrthContext;
import com.threerings.orth.ui.LoadingSpinner;

import mx.containers.Canvas;

import com.threerings.crowd.client.PlaceView;
import com.threerings.crowd.data.PlaceObject;

import com.threerings.flex.FlexWrapper;

/**
 * Displays a blank view when we have nothing else to display. Can optionally display our loading
 * graphics with a status message.
 */
public class BlankPlaceView extends Canvas
    implements PlaceView
{
    public function BlankPlaceView (ctx :OrthContext)
    {
        // we do some hackery here to obtain our width and height because we want to precisely
        // match the Preloader math which uses the full stage width and height, but our math is
        // going to be sullied by the header bar, embed bar and control bar *and* we are created
        // during TopPanel's constructor, so we can't ask it how big it is
        var swidth :int = ctx.getApplication().stage.stageWidth;
        var sheight :int = ctx.getApplication().stage.stageHeight;

        _spinner = new LoadingSpinner();
        addChild(new FlexWrapper(_spinner));
        _spinner.x = (swidth - LoadingSpinner.WIDTH) / 2;
        _spinner.y = (sheight - LoadingSpinner.HEIGHT) / 2;

        _spinner.setStatus(Msgs.GENERAL.get("m.ls_connecting"));
    }

    // from interface PlaceView
    public function willEnterPlace (plobj :PlaceObject) :void
    {
        // nada
    }

    // from interface PlaceView
    public function didLeavePlace (plobj :PlaceObject) :void
    {
        // nada
    }

    protected var _spinner :LoadingSpinner;
}
}
