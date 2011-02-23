//
// $Id: $

package com.threerings.orth.client {

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.display.Stage;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.events.Event;
import flash.geom.Rectangle;

import flashx.funk.ioc.inject;

import com.threerings.text.TextFieldUtil;
import com.threerings.util.Log;

import com.threerings.orth.chat.client.ChatInput;
import com.threerings.orth.chat.client.ChatOverlay;
import com.threerings.orth.chat.client.ComicOverlay;
import com.threerings.orth.chat.client.OrthChatDirector;

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

public class TopPanel extends Sprite
{
    /** An event dispatched when our location name changes. */
    public static const LOCATION_NAME_CHANGED :String = "locationNameChanged";

    /** An event dispatched when our location owner changes. */
    public static const LOCATION_OWNER_CHANGED :String = "locationOwnerChanged";

    public function TopPanel ()
    {
        _width = _stage.stageWidth;
        _height = _stage.stageHeight;

        var stretch :Sprite = new Sprite();
        stretch.alpha = 0.1;
        stretch.graphics.beginFill(0xFF5511);
        stretch.graphics.drawRect(0, 0, _width, _height);
        stretch.graphics.endFill();
        this.addChild(stretch);

        addChild(_controlBar.self());
        // I don't know what's up with the 40 here. The bottom of the stage won't show.
        _controlBar.self().y = height - getControlBarHeight() - 40;

        addChild(_placeBox);

        // show a subtle build-stamp on dev builds
        if (_depConf.development) {
            addChild(TextFieldUtil.createField(
                    "Build: " + _depConf.buildTime + "\nVersion: " + _depConf.version,
                { textColor: 0x0F7069A, selectable: false, wordWrap: false, x: 10, y: 10,
                  width: 100, outlineColor: 0x000000, autoSize: TextFieldAutoSize.LEFT },
                { font: "_sans", size: 8, bold: true }));
        }

        // ORTH TODO: something like this here?
        _chatDir.addChatDisplay(_comicOverlay);

        _stage.addEventListener(Event.RESIZE, stageResized);

        setMainView(getBlankPlaceView());

        // ORTH TODO - Quick hack to test chatting
        addChild(new ChatInput(150));
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
        // ORTH TODO: find another way of doing this
//        var left :Number = _placeBox.getStyle("left");
//        var top :Number = _placeBox.getStyle("top");
//        var width :Number = _width - _placeBox.getStyle("right") - left;
//        var height :Number = _height - _placeBox.getStyle("bottom") - top;
//        return new Rectangle(left, top, width, height);
        return new Rectangle(0, 0, _width, _height);
    }

    /**
     * Returns a rectangle in stage coordinates that specifies the main game area.  This is
     * basically just the bounds on the client, minus the any margins from control bar, etc.
     */
    public function getMainAreaBounds () :Rectangle
    {
        // ORTH TODO: find another way of doing this
//        var height: Number = _height - _placeBox.getStyle("bottom");
//        return new Rectangle(0, _placeBox.getStyle("top"), _width, height);
        return new Rectangle(0, 0, _width, _height);
    }

    protected function stageResized (event :Event) :void
    {
        layoutPanels();
    }

    protected function layoutPanels () :void
    {
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

        _comicOverlay.setTargetBounds(new Rectangle(0, 0, ChatOverlay.DEFAULT_WIDTH, h));

        // ORTH TODO: Find another way of doing this
//        _placeBox.setStyle("top", top);
//        _placeBox.setStyle("bottom", bottom);
//        _placeBox.setStyle("right", right);
//        _placeBox.setStyle("left", left);

        _placeBox.setActualSize(w, h - 40);
    }

    /**
     * To be overridden by subclasses that want to return something more interesting.
     */
    protected function getBlankPlaceView () :DisplayObject
    {
        var canvas :Sprite = new Sprite();
        canvas.graphics.beginFill(0x000000);
        canvas.graphics.drawRect(0, 0, _width, _height);
        canvas.graphics.endFill();
        return canvas;
    }

    protected const _stage :Stage = inject(Stage);
    protected const _placeBox :OrthPlaceBox = inject(OrthPlaceBox);
    protected const _controlBar :ControlBar = inject(ControlBar);
    protected const _depConf :OrthDeploymentConfig = inject(OrthDeploymentConfig);
    protected const _comicOverlay :ComicOverlay = inject(ComicOverlay);
    protected const _chatDir :OrthChatDirector = inject(OrthChatDirector);

    protected var _width :Number
    protected var _height :Number;
}
}
