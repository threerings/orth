//
// $Id: $

package com.threerings.orth.client {
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.display.Stage;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.geom.Rectangle;

import flashx.funk.ioc.inject;
import flashx.funk.util.isAbstract;

import com.threerings.orth.chat.client.ComicOverlay;
import com.threerings.orth.chat.client.OrthChatDirector;
import com.threerings.orth.client.ControlBar;
import com.threerings.orth.client.OrthPlaceBox;

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

    public static const CLIENT_WIDTH :int = 1024;
    public static const CLIENT_HEIGHT :int = 560;

    public function TopPanel ()
    {
        _width = CLIENT_WIDTH;
        _height = CLIENT_HEIGHT + _controlBar.getBarHeight();

        // configure the stage
        _stage.scaleMode = StageScaleMode.NO_SCALE;
        _stage.align = StageAlign.TOP_LEFT;

        // clip all drawing to our client bounds
        this.scrollRect = new Rectangle(0, 0, _width, _height);

        // var stretch :Sprite = new Sprite();
        // stretch.alpha = 0.2;
        // stretch.graphics.beginFill(0xFF5511);
        // stretch.graphics.drawRect(0, 0, _width, _height);
        // stretch.graphics.endFill();
        // this.addChild(stretch);

        this.addChild(_placeBox);
        this.addChild(_controlBar.asSprite());

        configureUI(_placeBox, _controlBar.asSprite());

        _chatDir.addChatDisplay(_comicOverlay);

        _stage.addEventListener(Event.RESIZE, function (event :Event) :void {
            needsLayout();
        });

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
        needsLayout();
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
     * Returns a rectangle in stage coordinates that specifies the main game area.  This is
     * basically just the bounds on the client, minus the any margins from control bar, etc.
     */
    public function getMainAreaBounds () :Rectangle
    {
        return new Rectangle(0, 0, _width, CLIENT_HEIGHT);
    }

    protected function configureUI (placeBox :DisplayObject, controlBar :DisplayObject) :void
    {
        isAbstract();
    }

    protected function needsLayout () :void
    {
        _width = CLIENT_WIDTH;
        _height = CLIENT_HEIGHT + _controlBar.getBarHeight();

        doLayout(_placeBox, _controlBar);
    }

    protected function doLayout (placeBox :OrthPlaceBox, controlBar :ControlBar) :void
    {
        placeBox.setActualSize(_width, CLIENT_HEIGHT);
        placeBox.x = 0;
        placeBox.y = 0;

        controlBar.asSprite().x = 0;
        controlBar.asSprite().y = CLIENT_HEIGHT;
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
