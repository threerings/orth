//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.client {

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.events.Event;
import flash.geom.Point;

import flashx.funk.ioc.inject;

import caurina.transitions.Tweener;

import mx.containers.Canvas;
import mx.containers.Tile;
import mx.containers.ViewStack;
import mx.core.Application;
import mx.core.UIComponent;
import mx.events.IndexChangedEvent;

import com.threerings.flex.CommandCheckBox;
import com.threerings.flex.FlexUtil;

import com.threerings.util.CommandEvent;

public class ButtonPalette extends Canvas
{
    public function ButtonPalette (parent :UIComponent, controlBarHeight: int, tileSize :int)
    {
        _controlBarHeight = controlBarHeight;
        _toggleWidth = tileSize;

        percentWidth = 100;
        height = _controlBarHeight;

        _toggle = new CommandCheckBox(null, showAll);
        _toggle.styleName = "panelToggle";
        _toggle.y = 5;
        addChild(_toggle);

        _tile = new Tile();
        _tile.tileWidth = tileSize;
        // TODO: why add "1"? do we need to pass in tileWidth & tileHeight?
        _tile.tileHeight = tileSize + 1;
        _tile.styleName = "buttonPalette";
        _tile.owner = DisplayObjectContainer(inject(Application).systemManager);

        CommandEvent.configureBridge(_tile, parent);

        addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
        addEventListener(Event.ADDED_TO_STAGE, handleAddRemove);
        addEventListener(Event.REMOVED_FROM_STAGE, handleAddRemove);

        minWidth = _toggleWidth + _tile.tileWidth + int(_tile.getStyle("paddingLeft")) +
            int(_tile.getStyle("paddingRight"));

        addEventListener(Event.RENDER, handleRender);
        showAll(false, false);
    }

    public function addButton (comp :UIComponent, priority :int) :void
    {
        _tile.addChild(comp);
    }

    public function clearButtons () :void
    {
        _tile.removeAllChildren();
    }

    public function recheckButtons () :void
    {
        invalidateSize();
        const hPad :int = int(_tile.getStyle("paddingLeft")) + int(_tile.getStyle("paddingRight"));
        const vPad :int = int(_tile.getStyle("paddingTop")) + int(_tile.getStyle("paddingBottom"));
        const hGap :int = int(_tile.getStyle("horizontalGap"));
        const adjustedWidth :int = this.width - _toggleWidth - hPad;
        const tileW :int = _tile.tileWidth;
        var w :int = tileW;
        while ((w + hGap + tileW) <= adjustedWidth) {
            w += hGap + tileW;
        }
        _tile.width = w + hPad;
        _tile.validateNow();
        const singleRow :Boolean = (_tile.height == (_tile.tileHeight + vPad));
        _toggle.visible = !singleRow;
        if (singleRow) {
            _toggle.selected = false;
            showAll(false, false);
        }
    }

    /**
     * Returns either the given component if it is in view, or the expander button that will
     * bring the given component into view when clicked. Returns null if the target is not
     * currently a descendant of the palette.
     */
    public function getClickableComponent (target :UIComponent) :UIComponent
    {
        if (target.parent != _tile) {
            return null;
        }
        if (!_toggle.visible || _up || target.y < _tile.tileHeight) {
            return target;
        }
        return _toggle;
    }

    override protected function measure () :void
    {
        super.measure();

        const hPad :int = int(_tile.getStyle("paddingLeft")) + int(_tile.getStyle("paddingRight"));
        const hGap :int = int(_tile.getStyle("horizontalGap"));
        const visChildren :int = FlexUtil.countLayoutChildren(_tile);

        // figure a maxWidth, so that the notification display can take the rest of the space
        maxWidth = _toggleWidth + hPad + (visChildren * _tile.tileWidth) +
            ((visChildren - 1) * hGap);
    }

    protected function updateTileLoc (animate :Boolean = false) :void
    {
        var y :int;
        if (_up) {
            y = -_tile.height + this.height;
        } else {
            y = (_controlBarHeight - (_tile.tileHeight + int(_tile.getStyle("paddingTop")))) / 2;
        }
        const downAlpha :Number = Number(_tile.getStyle("backgroundAlphaClosed"));
        const upAlpha :Number = Number(_tile.getStyle("backgroundAlphaOpen"));

        var p :Point = localToGlobal(new Point(_toggleWidth, y));
        p = _tile.owner.globalToLocal(p);

        if (animate) {
            // we make crafty use of the data property, since I can figure out otherwise how
            // to call a function..
            _tile.data = _up ? downAlpha : upAlpha; // set the starting alpha
            // during each step of the tween, copy the 'data' to the backgroundAlpha
            var fn :Function = function () :void {
                _tile.setStyle("backgroundAlpha", Number(_tile.data));
            };

            // tween the y and the alpha level, which is slapped into the 'data' property
            Tweener.addTween(_tile,
                { time: .75, y: p.y, data: _up ? upAlpha : downAlpha,
                  onUpdate: fn, transition: "easeinoutcubic" });

        } else {
            Tweener.removeTweens(_tile);
            _tile.move(p.x, p.y);
            _tile.setStyle("backgroundAlpha", _up ? upAlpha : downAlpha);
        }
    }

    /**
     * Should we show all the buttons?
     */
    protected function showAll (show :Boolean, animate :Boolean = true) :void
    {
        _up = show;
        updateTileLoc(animate);
    }

    override protected function updateDisplayList (uw :Number, uh :Number) :void
    {
        super.updateDisplayList(uw, uh);
        recheckButtons();
    }

    protected function handleRender (event :Event) :void
    {
        // gah, we suppress redoing this too often, or we kill our own animation
        var p :Point = localToGlobal(new Point());
        if (!_lastPoint.equals(p)) {
            _lastPoint = p;
            updateTileLoc();
        }
    }

    protected function handleAddRemove (event :Event) :void
    {
        if (event.type == Event.ADDED_TO_STAGE) {
            _tile.owner.addChild(_tile);
        } else {
            _tile.owner.removeChild(_tile);
        }
    }

    /**
     * In the remixer, our buttons show up even in the image editing phase because
     * the Tile is added as a child to the top-level systemManager. I tried
     * adding it to the most local systemManager, but then it doesn't even show up-
     * it seems to size at 0 or something.
     * So- we just see if we're in a ViewStack and listen to see when we're hidden,
     * and also hide the Tile.
     */
    protected function handleAddedToStage (event :Event) :void
    {
        var d :DisplayObject = this;
        while (d != null) {
            if (d is ViewStack) {
                d.addEventListener(IndexChangedEvent.CHANGE, handleViewStackChanged,
                    false, 0, true);
                return;
            }
            d = d.parent;
        }
    }

    protected function handleViewStackChanged (event :IndexChangedEvent) :void
    {
        _tile.visible = DisplayObjectContainer(event.relatedObject).contains(this);
    }

    protected var _controlBarHeight :int;

    protected var _toggleWidth :int;

    protected var _toggle :CommandCheckBox;

    protected var _tile :Tile;

    protected var _up :Boolean;

    protected var _lastPoint :Point = new Point(0, 0);
}
}
