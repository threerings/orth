//
// $Id: MsoyMediaContainer.as 19632 2010-11-26 16:25:14Z zell $

package com.threerings.orth.ui {

import com.threerings.media.MediaContainer;
import com.threerings.orth.data.ClientMediaDesc;
import com.threerings.util.Util;

import com.threerings.orth.data.MediaDesc;

public class MediaDescContainer extends MediaContainer
{
    public function MediaDescContainer (desc: ClientMediaDesc = null)
    {
        super(null);

        if (desc != null) {
            setMediaDesc(desc);
        }
    }

    /**
     * ATTENTION: don't use this method in unless you know what you're doing.
     * This class almost always wants MediaDescs rather than URLs.
     */
    override public function setMedia (url :String) :void
    {
        // this method exists purely for the change in documentation.
        super.setMedia(url);
    }

    /**
     * Set a new MediaDescriptor. Returns true if the descriptor really changed.
     */
    public function setMediaDesc (desc :ClientMediaDesc) :Boolean
    {
        if (Util.equals(desc, _desc)) {
            return false;
        }

        _desc = desc;
        super.setMedia((desc == null) ? null : desc.getMediaPath());
        return true;
    }

    /**
     * Retrieve the MediaDescriptor we're configured with, or null if we're not fully configured
     * yet, or media was configured through setMedia().
     */
    public function getMediaDesc () :MediaDesc
    {
        return _desc;
    }

    override public function toString () :String
    {
        return "MediaDescContainer[desc=" + _desc + "]";
    }

    /** Our Media descriptor. */
    protected var _desc :ClientMediaDesc;
}
}
