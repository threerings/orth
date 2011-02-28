//
// $Id: ScalingMsoyMediaContainer.as 19431 2010-10-22 22:08:36Z zell $

package com.threerings.orth.ui {
import com.threerings.orth.data.MediaDesc;
import com.threerings.orth.data.MediaDescSize;

public class ScalingMediaDescContainer extends MediaDescContainer
{
    /**
     * Factory to create a MediaContainer for viewing a MediaDesc.
     */
    public static function createView (desc :MediaDesc, size :int = MediaDescSize.THUMBNAIL_SIZE)
        :ScalingMediaDescContainer
    {
        var smc :ScalingMediaDescContainer = new ScalingMediaDescContainer(
            MediaDescSize.getWidth(size), MediaDescSize.getHeight(size), true);
        smc.setMediaDesc(desc);
        return smc;
    }

    // -- End: static methods

    /** Publicly available, but do not change. */
    public var maxW :int;
    public var maxH :int;

    /**
     * @param center if true, the actual media will be centered within the maximum size if
     * it is smaller in either dimension.
     */
    public function ScalingMediaDescContainer (
        maxWidth :int, maxHeight :int, center :Boolean = true)
    {
        if (maxWidth == 0 || maxHeight == 0) {
            throw new Error("Requested scaling media container with invalid dimensions " +
                            maxWidth + "x" + maxHeight);
        }
        maxW = maxWidth;
        maxH = maxHeight;
        _center = center;
    }

    override public function getMediaScaleX () :Number
    {
        return _mediaScale;
    }

    override public function getMediaScaleY () :Number
    {
        return _mediaScale;
    }

    override protected function contentDimensionsUpdated () :void
    {
        super.contentDimensionsUpdated();

        _mediaScale = Math.min(1, Math.min(maxW / _w, maxH / _h));
        _media.scaleX = _mediaScale;
        _media.scaleY = _mediaScale;

        if (_center) {
            _media.x = (maxW - (_w * _mediaScale)) / 2;
            _media.y = (maxH - (_h * _mediaScale)) / 2;
        }
    }

    protected var _mediaScale :Number = 1;
    protected var _center :Boolean;
}
}
