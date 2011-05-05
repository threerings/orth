//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.room.client.editor {

import flash.display.DisplayObject;
import flash.events.MouseEvent;
import flash.geom.Point;

import com.threerings.util.Log;

import com.threerings.orth.client.Msgs;

/**
 * Hotspot that scales the object based on user's mouse movement.
 */
public class ScalingHotspot extends Hotspot
{
    public function ScalingHotspot (editor :FurniEditor, top :Boolean, left :Boolean)
    {
        super(editor, false);
        _corner = new Point(left ? 0 : 1, top ? 0 : 1);
    }

    // @Override from Hotspot
    override public function updateDisplay (targetWidth :Number, targetHeight :Number) :void
    {
        super.updateDisplay(targetWidth, targetHeight);

        this.x = _corner.x * targetWidth;
        this.y = _corner.y * targetHeight;
    }

    // @Override from Hotspot
    override protected function startAction (event :MouseEvent) :void
    {
        super.startAction(event);
        _originalScale = new Point(
            _editor.target.viz.getMediaScaleX(), _editor.target.viz.getMediaScaleY());
    }

    // @Override from Hotspot
    override protected function updateAction (event :MouseEvent) :void
    {
        super.updateAction(event);
        updateTargetScale(event);
    }

    // @Override from Hotspot
    override protected function endAction (event :MouseEvent) :void
    {
        super.endAction(event);
        _originalScale = null;
    }

    // @Override from Hotspot
    override protected function initializeDisplay () :void
    {
        var klass :Class = _editor.rsrc.edHotspotScale;
        _displayStandard = new klass() as DisplayObject;

        var c :Class = (_corner.x == _corner.y) ?
            _editor.rsrc.edHotspotScaleOverLeft : _editor.rsrc.edHotspotScaleOverRight;
        _displayMouseOver = new c() as DisplayObject;
    }

    /**
     * Computes target's furni scale based on a dragging action, and updates the editor.
     */
    protected function updateTargetScale (event :MouseEvent) :void
    {
        if (_editor.target == null) {
            Log.getLog(this).warning("Scaling hotspot updated without an editing target!");
            return;
        }

        // find pixel distance from hotspot to the current and the original mouse pointer
        var mouse :Point = new Point(event.stageX, event.stageY);
        var newoffset :Point = mouse.subtract(_originalHotspot);
        var oldoffset :Point = _anchor.subtract(_originalHotspot);

        // find scaling factor based on mouse movement
        var ratioX :Number = newoffset.x / oldoffset.x;
        var ratioY :Number = newoffset.y / oldoffset.y;

        // if the original mouse pointer was roughly axis-aligned with the furni hotspot,
        // ignore scaling along that axis, because it's going to be very very noisy
        if (Math.abs(oldoffset.x) < 5) {
            ratioX = 20.0; // large value, so that the other axis will dominate
        }
        if (Math.abs(oldoffset.y) < 5) {
            ratioY = 20.0; // as above
        }

        var x :Number = ratioX * _originalScale.x;
        var y :Number = ratioY * _originalScale.y;

        // should we snap?
        var noSnap :Boolean = event.shiftKey || event.altKey || event.ctrlKey;
        if (!noSnap) {
            var scale :Number = Math.min(Math.abs(x), Math.abs(y));
            x = scale * ((x < 0) ? -1 : 1);
            y = scale * ((y < 0) ? -1 : 1);
        }

        // don't allow for flipping during scaling - we'll have a separate button for that
        if (x < 0 && _originalScale.x >= 0 || x > 0 && _originalScale.x <= 0) {
            x = -x;
        }
        if (y < 0 && _originalScale.y >= 0 || y > 0 && _originalScale.y <= 0) {
            y = -y;
        }

        // finally, scale!
        _editor.updateTargetScale(x, y);
    }

    override protected function getToolTip () :String
    {
        return Msgs.EDITING.get("i.scaling");
    }

    /** Specifies which corner of the furni we occupy. */
    protected var _corner :Point;

    /** Sprite scale at the beginning of modifications. Only valid during action. */
    protected var _originalScale :Point;

    /** Bitmap used for hotspot with no scale locking. */
    protected var _displayUnlocked :DisplayObject;
}
}
