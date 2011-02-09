//
// $Id: $

package com.threerings.orth.client {

import flash.display.DisplayObject;
import flash.display.Stage;
import flash.events.Event;
import flash.geom.Rectangle;

import flashx.funk.ioc.inject;

import mx.containers.Canvas;
import mx.controls.Label;
import mx.controls.scrollClasses.ScrollBar;
import mx.core.Application;
import mx.core.ScrollPolicy;

// import com.threerings.orth.chat.client.ComicOverlay;

/**
 * Dispatched when the name of our current location changes. The value supplied will be a string
 * with the new location name.
 *
 * @eventType com.threerings.msoy.client.TopPanel.LOCATION_NAME_CHANGED
 */
[Event(name="locationNameChanged", type="com.threerings.util.ValueEvent")]

/**
 * Dispatched when the owner for our current location changes. The value supplied will either be a
 * MemberName or a GroupName, or null if we move to a location with no owner.
 *
 * @eventType com.threerings.msoy.client.TopPanel.LOCATION_OWNER_CHANGED
 */
[Event(name="locationOwnerChanged", type="com.threerings.util.ValueEvent")]

public class TopPanel extends Canvas
{
    /** An event dispatched when our location name changes. */
    public static const LOCATION_NAME_CHANGED :String = "locationNameChanged";

    /** An event dispatched when our location owner changes. */
    public static const LOCATION_OWNER_CHANGED :String = "locationOwnerChanged";

    public function TopPanel ()
    {
        _width = inject(Stage).stageWidth;
        _height = inject(Stage).stageHeight;

        percentWidth = 100;
        percentHeight = 100;
        verticalScrollPolicy = ScrollPolicy.OFF;
        horizontalScrollPolicy = ScrollPolicy.OFF;
        styleName = "topPanel";

        _placeBox.autoLayout = false;
        _placeBox.includeInLayout = false;
        addChild(_placeBox);

        // set up the control bar
        _controlBar.includeInLayout = false;
        _controlBar.init(this);
        _controlBar.setStyle("left", 0);
        _controlBar.setStyle("right", 0);
        addChild(_controlBar);

        // show a subtle build-stamp on dev builds

        var depConf: OrthDeploymentConfig = inject(OrthDeploymentConfig);
        if (depConf.development) {
            var buildStamp :Label = new Label();
            buildStamp.includeInLayout = false;
            buildStamp.mouseEnabled = false;
            buildStamp.mouseChildren = false;
            buildStamp.text = "Build: " + depConf.version;
            buildStamp.setStyle("color", "#F7069A");
            buildStamp.setStyle("fontSize", 8);
            buildStamp.setStyle("bottom", getControlBarHeight());
            // The scrollbar isn't really this thick, but it's pretty close.
            buildStamp.setStyle("right", ScrollBar.THICKNESS);
            addChild(buildStamp);
        }

        // ORTH TODO: something like this here?
        // _chatDir.addChatDisplay(_comicOverlay);

        // clear out the application and install ourselves as the only child
        _app.removeAllChildren();
        _app.addChild(this);
        _app.stage.addEventListener(Event.RESIZE, stageResized);

        setMainView(getBlankPlaceView());
    }

    /**
     * Gets the height of the area at the bottom of the screen that contains the control bar.
     */
    public function getControlBarHeight () :Number
    {
        return _controlBar.getBarHeight();
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

        // ORTH TODO: Something like this?
        // _comicOverlay.displayChat();
    }

    /**
     * Clear the specified place view, or null to clear any.
     */
    public function clearMainView (view :DisplayObject = null) :void
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

        // center control bar in the "footer". we shall put other things here soon
        _controlBar.setStyle("bottom", 0);

        updatePlaceViewSize();
    }

    protected function updatePlaceViewSize () :void
    {
        if (_placeBox.parent != this) {
            return; // nothing doing if we're not in control
        }

        var top :int = 0;
        var left :int = 0;
        var right :int = 0;
        var bottom :int = 0;
        var w :int = _width;
        var h :int = _height;

        bottom += getControlBarHeight();
        h -= getControlBarHeight();

        // ORTH TODO: Somethign like this?
        // _comicOverlay.setTargetBounds(new Rectangle(0, 0, ChatOverlay.DEFAULT_WIDTH, h));

        _placeBox.setStyle("top", top);
        _placeBox.setStyle("bottom", bottom);
        _placeBox.setStyle("right", right);
        _placeBox.setStyle("left", left);
        _placeBox.setActualSize(w, h);
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

    protected const _app :Application = inject(Application);
    protected const _placeBox :OrthPlaceBox = inject(OrthPlaceBox);
    protected const _controlBar :ControlBar = inject(ControlBar);
//    protected const _comicOverlay :ComicOverlay = inject(ComicOverlay);

    protected var _width :Number
    protected var _height :Number;
}
}
