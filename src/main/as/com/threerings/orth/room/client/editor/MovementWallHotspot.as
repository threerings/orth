//
// $Id: MovementWallHotspot.as 15000 2009-02-24 00:24:42Z mdb $

package com.threerings.orth.room.client.editor {

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Shape;
import flash.events.MouseEvent;
import flash.geom.Point;

import com.threerings.orth.client.OrthPlaceBox;
import com.threerings.orth.room.client.ClickLocation;

/**
 * Hotspot that covers the entire furni, and projects it onto the nearest wall.
 */
public class MovementWallHotspot extends Hotspot
{
    public function MovementWallHotspot (editor :FurniEditor)
    {
        super(editor, false);
    }

    // @Override from Hotspot
    override public function updateDisplay (targetWidth :Number, targetHeight :Number) :void
    {
        super.updateDisplay(targetWidth, targetHeight);

        // center this hotspot on the object
        this.x = targetWidth / 2;
        this.y = targetHeight / 2;

        if (targetWidth != _lastSize.x || targetHeight != _lastSize.y) {

            _lastSize.x = targetWidth;
            _lastSize.y = targetHeight;

            var g :Graphics = (_displayStandard as Shape).graphics;
            g.clear();
            g.beginFill(0xffffff, 0.0);
            g.drawRect(0, 0, targetWidth, targetHeight);
            g.endFill();

            g = (_displayMouseOver as Shape).graphics;
            g.clear();
            g.beginFill(0xffffff, 0.0);
            g.drawRect(0, 0, targetWidth, targetHeight);
            g.endFill();

            // force a resize
            adjustCurrentBitmapPosition();
        }
    }

    // @Override from Hotspot
    override protected function switchDisplay (display :DisplayObject) :void
    {
        super.switchDisplay(display);

        // the superclass's version of this function will try to center display bitmaps on the
        // location of this hotspot. but for this particular case, because the bitmap is created
        // at runtime, its width and height will always show up as zero, causing layout to fail.
        // so we need to adjust it manually in this case.

        adjustCurrentBitmapPosition();
    }

    // @Override from Hotspot
    override protected function updateAction (event :MouseEvent) :void
    {
        super.updateAction(event);

        updateTargetLocation(event.stageX, event.stageY);
    }

    // @Override from Hotspot
    override protected function initializeDisplay () :void
    {
        // initial versions of the mouseover/mouseout images.
        _displayStandard = new Shape();
        _displayMouseOver = new Shape();
    }

    /** Called when the target is updated, moves the hotspot's current bitmap appropriately. */
    protected function adjustCurrentBitmapPosition () :void
    {
        if (_currentDisplay != null) {
            _currentDisplay.x = - _lastSize.x / 2;
            _currentDisplay.y = - _lastSize.y / 2;
        }
    }

    /** Moves the furni over to the new location. */
    protected function updateTargetLocation (sx :Number, sy :Number) :void
    {
        sx -= (_anchor.x - _originalHotspot.x);
        sy -= (_anchor.y - _originalHotspot.y);

        // clamp against the place view
        var placeBox :OrthPlaceBox = _editor.controller.topPanel.getPlaceContainer();
        sy = Math.min(sy, placeBox.height + placeBox.y);

        var cloc :ClickLocation = _editor.roomView.layout.pointToFurniLocation(sx, sy);
        if (cloc != null) {
            _editor.updateTargetLocation(cloc.loc);
        }
    }

    /** Last known target dimensions. */
    protected var _lastSize :Point = new Point();
}
}
