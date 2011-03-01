//
// $Id: RotatingHotspot.as 19622 2010-11-23 22:59:49Z zell $

package com.threerings.orth.room.client.editor {

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;

import com.threerings.util.MathUtil;
import com.threerings.geom.Vector2;

import com.threerings.orth.client.Msgs;
import com.threerings.orth.entity.client.EntitySprite;

/**
 * Hotspot that rotates the object.
 */
public class RotatingHotspot extends Hotspot
{
    public function RotatingHotspot (editor :FurniEditor, top :Boolean, left :Boolean)
    {
        super(editor, false);
        _corner = new Point(left ? 0 : 1, top ? 0 : 1);
    }

    // @Override from Hotspot
    override public function updateDisplay (targetWidth :Number, targetHeight :Number) :void
    {
        super.updateDisplay(targetWidth, targetHeight);

        this.x = _corner.x * (targetWidth + 2 * this.width) - (this.width / 2);
        this.y = _corner.y * (targetHeight + 2 * this.height) - (this.height / 2);
    }

    // @Override from Hotspot
    override protected function startAction (event :MouseEvent) :void
    {
        super.startAction(event);
        _originalRotation = _editor.target.getMediaRotation();
        _anchorAngle = Vector2.fromPoints(
            _editor.target.getMediaCentroid(), _editor.target.viz.globalToLocal(_anchor)).angle;
    }

    // @Override from Hotspot
    override protected function updateAction (event :MouseEvent) :void
    {
        super.updateAction(event);
        updateTargetRotation(event.stageX, event.stageY);
    }

    // @Override from Hotspot
    override protected function endAction (event :MouseEvent) :void
    {
        super.endAction(event);
        _originalRotation = 0;
        _anchorAngle = 0;
    }

    // @Override from Hotspot
    override protected function initializeDisplay () :void
    {
        var s :Sprite = new Sprite();
        var g :Graphics = s.graphics;
        g.beginFill(0xFFFFFF, 0);
        g.drawRect(0, 0, 21, 21);
        g.endFill();
        _displayStandard = s;

        var klass :Class = _editor.rsrc.edHotspotRotating;
        _displayMouseOver = new klass() as DisplayObject;

        var rot :Number = Math.abs((_corner.y * 270) + (_corner.x * -90)); // magic!
        _displayMouseOver.rotation = rot;
        s.rotation = rot;
    }

    override protected function getToolTip () :String
    {
        return Msgs.EDITING.get("i.rotation");
    }

    /** Moves the furni over to the new location. */
    protected function updateTargetRotation (sx :Number, sy :Number) :void
    {
        var target :EntitySprite = _editor.target;
        if (target == null) {
            return;
        }

        var mouseAngle :Number = Vector2.fromPoints(
            target.getMediaCentroid(), target.viz.globalToLocal(new Point(sx, sy))).angle;
        var delta :Number = MathUtil.toDegrees(mouseAngle - _anchorAngle);

        _editor.updateTargetRotation(MathUtil.normalizeDegrees(_originalRotation + delta));
    }

    /** Specifies which corner of the furni we occupy. */
    protected var _corner :Point;

    /** Sprite rotation at the beginning of modifications. Only valid during action. */
    protected var _originalRotation :Number;

    /** Angle to the original mouse anchor (in trig radians). */
    protected var _anchorAngle :Number;
}
}
