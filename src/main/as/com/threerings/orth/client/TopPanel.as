//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.client {

import com.threerings.util.StageLifetime;
import com.threerings.util.Util;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.display.Stage;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.geom.Rectangle;

import flashx.funk.ioc.inject;
import flashx.funk.util.isAbstract;

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

    public function TopPanel (trackStageSize :Boolean = true)
    {
        _trackStageSize = trackStageSize;

        // configure the stage
        _stage.scaleMode = StageScaleMode.NO_SCALE;
        _stage.align = StageAlign.TOP_LEFT;

        _width = _stage.stageWidth;
        _height = _stage.stageHeight;

        // clip all drawing to our client bounds
        this.scrollRect = new Rectangle(0, 0, _width, _height);

        this.addChild(_placeBox);

        configureUI(_placeBox);


        _stage.addEventListener(Event.RESIZE, function (event :Event) :void {
            if (_trackStageSize) {
                _width = _stage.stageWidth;
                _height = _stage.stageHeight;
            }
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
    public function clearMainView () :void
    {
        if (_placeBox.clearMainView()) {
            setMainView(getBlankPlaceView());
        }
    }

    /**
     * Returns a rectangle in stage coordinates that specifies the main game area.  This is
     * basically just the bounds on the client, minus the any margins from control bar, etc.
     */
    public function getMainAreaBounds () :Rectangle
    {
        return new Rectangle(0, 0, _width, _height);
    }

    protected function configureUI (placeBox :DisplayObject) :void
    {
        isAbstract();
    }

    protected function needsLayout () :void
    {
        doLayout(_placeBox);
    }

    protected function doLayout (placeBox :OrthPlaceBox) :void
    {
        placeBox.setActualSize(_width, _height);
        placeBox.x = 0;
        placeBox.y = 0;
    }

    /**
     * To be overridden by subclasses that want to return something more interesting.
     */
    protected function getBlankPlaceView () :DisplayObject
    {
        var canvas :Sprite = new Sprite();
        function fill () :void {
            canvas.graphics.beginFill(0x000000);
            canvas.graphics.drawRect(0, 0, _width, _height);
            canvas.graphics.endFill();
        }
        if (_trackStageSize) {
            StageLifetime.listenForSizeChange(canvas, Util.adapt(fill));
        } else {
            fill();
        }
        return canvas;
    }

    protected const _stage :Stage = inject(Stage);
    protected const _placeBox :OrthPlaceBox = inject(OrthPlaceBox);
    protected const _depConf :OrthDeploymentConfig = inject(OrthDeploymentConfig);

    protected var _trackStageSize :Boolean;
    protected var _width :Number
    protected var _height :Number;
}
}
