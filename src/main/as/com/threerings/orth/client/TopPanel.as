//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.client {

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.display.Stage;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.geom.Point;
import flash.geom.Rectangle;

import flashx.funk.ioc.inject;
import flashx.funk.util.isAbstract;

import com.threerings.util.StageLifetime;
import com.threerings.util.ValueEvent;

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

/**
 * Dispatched when the width and height of the top panel changes. Note that this is a distinct
 * concept from DisplayObject width and height since we store separate members so that the place
 * box and layers can update accordingly. The value is a Point object with x = width and
 * y = height.
 *
 * @eventType com.threerings.msoy.client.TopPanel.SIZE_CHANGED
 */
[Event(name="sizeChanged", type="com.threerings.util.ValueEvent")]

public class TopPanel extends Sprite
{
    /** An event dispatched when our location name changes. */
    public static const LOCATION_NAME_CHANGED :String = "locationNameChanged";

    /** An event dispatched when our location owner changes. */
    public static const LOCATION_OWNER_CHANGED :String = "locationOwnerChanged";

    /** An event dispatched when our size changes. */
    public static const SIZE_CHANGED :String = "sizeChanged";

    /**
     * Creates a new top panel. Initially the size of the top panel is set to the stage size.
     * Subclasses can change this later using setSize.
     * @param trackStageSize if set, then whenever the stage size changes, the top panel will set
     * its size to the new stage size.
     * @see flash.events.Event#RESIZE
     */
    public function TopPanel (trackStageSize :Boolean = true)
    {
        _trackStageSize = trackStageSize;

        // configure the stage
        _stage.scaleMode = StageScaleMode.NO_SCALE;
        _stage.align = StageAlign.TOP_LEFT;

        this.addChild(_placeBox);

        setSize(_stage.stageWidth, _stage.stageHeight);

        configureUI(_placeBox);

        _stage.addEventListener(Event.RESIZE, function (event :Event) :void {
            if (_trackStageSize) {
                setSize(_stage.stageWidth, _stage.stageHeight);
            } else {
                needsLayout();
            }
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

    /**
     * Guarantees that the given listener function will be notified with a SIZE_CHANGED ValueEvent
     * any time the given display object is added to the stage (including now if it is already on)
     * or the top panel size changes.
     * @see TopPanel#SIZE_CHANGED
     */
    public function trackSize (disp :DisplayObject, listener :Function) :void
    {
        StageLifetime.listen(disp, function (_:*) :void {
            addEventListener(SIZE_CHANGED, listener);
            listener(makeSizeChangedEvent());
        }, function (_:*) :void {
            removeEventListener(SIZE_CHANGED, listener);
        }, true);
    }

    protected function setSize (w :Number, h :Number) :void
    {
        _width = w;
        _height = h;

        // clip all drawing to our client bounds
        scrollRect = new Rectangle(0, 0, w, h);

        needsLayout();

        dispatchEvent(makeSizeChangedEvent());
    }

    protected function makeSizeChangedEvent () :ValueEvent
    {
        return new ValueEvent(SIZE_CHANGED, new Point(_width, _height));
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
        trackSize(canvas, function (e :ValueEvent) :void {
            canvas.graphics.clear();
            canvas.graphics.beginFill(0x000000);
            canvas.graphics.drawRect(0, 0, e.value.x, e.value.y);
            canvas.graphics.endFill();
        });
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
