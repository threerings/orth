//
// $Id: $

package com.threerings.orth.client {

import flash.events.Event;
import flash.geom.Rectangle;

import mx.core.Application;
import mx.core.ScrollPolicy;

import mx.containers.Canvas;

import mx.controls.Label;
import mx.controls.scrollClasses.ScrollBar;

import com.threerings.crowd.client.PlaceView;

public class TopPanel extends Canvas
{
    /**
     * Construct the top panel.
     */
    public function TopPanel (octx :OrthContext)
    {
        _octx = octx;
        percentWidth = 100;
        percentHeight = 100;
        verticalScrollPolicy = ScrollPolicy.OFF;
        horizontalScrollPolicy = ScrollPolicy.OFF;
        styleName = "topPanel";

        _placeBox = new PlaceBox(_octx);
        _placeBox.autoLayout = false;
        _placeBox.includeInLayout = false;
        addChild(_placeBox);

        // show a subtle build-stamp on dev builds
        if (_octx.deployment.isDevelopment()) {
            var buildStamp :Label = new Label();
            buildStamp.includeInLayout = false;
            buildStamp.mouseEnabled = false;
            buildStamp.mouseChildren = false;
            buildStamp.text = "Build: " + _octx.deployment.getVersion();
            buildStamp.setStyle("color", "#F7069A");
            buildStamp.setStyle("fontSize", 8);
            buildStamp.setStyle("bottom", 0);
            // The scrollbar isn't really this thick, but it's pretty close.
            buildStamp.setStyle("right", ScrollBar.THICKNESS);
            addChild(buildStamp);
        }

        // clear out the application and install ourselves as the only child
        var app :Application = _octx.app;
        app.removeAllChildren();
        app.addChild(this);
        app.stage.addEventListener(Event.RESIZE, stageResized);

        // display something until someone comes along and sets a real view on us
        setPlaceView(new BlankPlaceView(_octx));
    }

    /**
     * Get the flex container that is holding the PlaceView. This is useful if you want to overlay
     * things over the placeview or register to receive flex-specific events.
     */
    public function getPlaceContainer () :PlaceBox
    {
        return _placeBox;
    }

    /**
     * Returns the currently configured place view.
     */
    public function getPlaceView () :PlaceView
    {
        return _placeBox.getPlaceView();
    }

    /**
     * Sets the specified view as the current place view.
     */
    public function setPlaceView (view :PlaceView) :void
    {
        _placeBox.setPlaceView(view);
        layoutPanels();
    }

    /**
     * Clear the specified place view, or null to clear any.
     */
    public function clearPlaceView (view :PlaceView) :void
    {
        if (_placeBox.clearPlaceView(view)) {
            setPlaceView(new BlankPlaceView(_octx));
        }
    }

    /**
     * Returns the location and dimensions of the place view in relation to the entire stage.
     */
    public function getPlaceViewBounds () :Rectangle
    {
        var left :Number = _placeBox.getStyle("left");
        var top :Number = _placeBox.getStyle("top");
        var width :Number = _octx.getWidth() - _placeBox.getStyle("right") - left;
        var height :Number = _octx.getHeight() - _placeBox.getStyle("bottom") - top;
        return new Rectangle(left, top, width, height);
    }

    /**
     * Returns a rectangle in stage coordinates that specifies the main game area.  This is
     * basically just the bounds on the client, minus the any margins from control bar, etc.
     */
    public function getMainAreaBounds () :Rectangle
    {
        var height: Number = _octx.getHeight() - _placeBox.getStyle("bottom");
        return new Rectangle(0, _placeBox.getStyle("top"), _octx.getWidth(), height);
    }

    protected function stageResized (event :Event) :void
    {
        layoutPanels();
    }

    protected function layoutPanels () :void
    {
        // Pin the app to the stage.
        // This became necessary for "stubs" after we upgraded to flex 3.2.
        _octx.app.width = _octx.getWidth();
        _octx.app.height = _octx.getHeight();

        updatePlaceViewSize();
    }

    protected function updatePlaceViewSize () :void
    {
        if (_placeBox.parent != this) {
            return; // nothing doing if we're not in control
        }

        // w -= ScrollBar.THICKNESS;
        _placeBox.setStyle("top", 0);
        _placeBox.setStyle("bottom", 0);
        _placeBox.setStyle("right", 0);
        _placeBox.setStyle("left", 0); // + ScrollBar.THICKNESS);
        _placeBox.setActualSize(_octx.getWidth(), _octx.getHeight());
    }

    /** The giver of life. */
    protected var _octx :OrthContext;

    /** The box that will hold the placeview. */
    protected var _placeBox :PlaceBox;
}
}