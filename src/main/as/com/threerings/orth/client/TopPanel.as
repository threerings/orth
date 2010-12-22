//
// $Id: $

package com.threerings.orth.client {

import flash.display.DisplayObject;
import flash.events.Event;
import flash.geom.Rectangle;

import mx.core.Application;
import mx.core.ScrollPolicy;

import mx.containers.Canvas;

import mx.controls.Label;
import mx.controls.scrollClasses.ScrollBar;

public class TopPanel extends Canvas
{
    [PostConstruct]
    public function initTopPanel () :void
    {
        percentWidth = 100;
        percentHeight = 100;
        verticalScrollPolicy = ScrollPolicy.OFF;
        horizontalScrollPolicy = ScrollPolicy.OFF;
        styleName = "topPanel";

        _placeBox.autoLayout = false;
        _placeBox.includeInLayout = false;
        addChild(_placeBox);

        // show a subtle build-stamp on dev builds
        if (_devConf.isDevelopment()) {
            var buildStamp :Label = new Label();
            buildStamp.includeInLayout = false;
            buildStamp.mouseEnabled = false;
            buildStamp.mouseChildren = false;
            buildStamp.text = "Build: " + _devConf.getVersion();
            buildStamp.setStyle("color", "#F7069A");
            buildStamp.setStyle("fontSize", 8);
            buildStamp.setStyle("bottom", 0);
            // The scrollbar isn't really this thick, but it's pretty close.
            buildStamp.setStyle("right", ScrollBar.THICKNESS);
            addChild(buildStamp);
        }

        // clear out the application and install ourselves as the only child
        var app :Application = _app;
        app.removeAllChildren();
        app.addChild(this);
        app.stage.addEventListener(Event.RESIZE, stageResized);

        setMainView(getBlankPlaceView());
    }

    /**
     * Get the flex container that is holding the PlaceView. This is useful if you want to overlay
     * things over the placeview or register to receive flex-specific events.
     */
    public function getPlaceContainer () :OrthPlaceBox
    {
        return _placeBox;
    }

    /**
     * Returns the currently configured place view.
     */
    public function getMainView () :DisplayObject
    {
        return _placeBox.getMainView();
    }

    /**
     * Sets the specified view as the current place view.
     */
    public function setMainView (view :DisplayObject) :void
    {
        _placeBox.setMainView(view);
        layoutPanels();
    }

    /**
     * Clear the specified place view, or null to clear any.
     */
    public function clearPlaceView (view :DisplayObject) :void
    {
        if (_placeBox.clearMainView(view)) {
            setMainView(getBlankPlaceView());
        }
    }

    /**
     * Returns the location and dimensions of the place view in relation to the entire stage.
     */
    public function getPlaceViewBounds () :Rectangle
    {
        var left :Number = _placeBox.getStyle("left");
        var top :Number = _placeBox.getStyle("top");
        var width :Number = _width - _placeBox.getStyle("right") - left;
        var height :Number = _height - _placeBox.getStyle("bottom") - top;
        return new Rectangle(left, top, width, height);
    }

    /**
     * Returns a rectangle in stage coordinates that specifies the main game area.  This is
     * basically just the bounds on the client, minus the any margins from control bar, etc.
     */
    public function getMainAreaBounds () :Rectangle
    {
        var height: Number = _height - _placeBox.getStyle("bottom");
        return new Rectangle(0, _placeBox.getStyle("top"), _width, height);
    }

    protected function stageResized (event :Event) :void
    {
        layoutPanels();
    }

    protected function layoutPanels () :void
    {
        // Pin the app to the stage.
        // This became necessary for "stubs" after we upgraded to flex 3.2.
        _app.width = _width;
        _app.height = _height;

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
        _placeBox.setActualSize(_width, _height);
    }

    /**
     * To be overridden by subclasses that want to return something more interesting.
     */
    protected function getBlankPlaceView () :DisplayObject
    {
        var canvas :Canvas = new Canvas();
        canvas.setStyle("background-color", "#663300");
        return canvas;
    }

    [Inject] public var _app :Application;
    [Inject] public var _devConf :OrthDeploymentConfig;
    [Inject] public var _placeBox :OrthPlaceBox;

    [Inject(name="clientWidth")] public var _width :Number
    [Inject(name="clientHeight")] public var _height :Number;
}
}
