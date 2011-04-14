//
// $Id: MsoyMediaContainer.as 19632 2010-11-26 16:25:14Z zell $

package com.threerings.orth.ui {

import com.threerings.media.MediaContainer;

import com.threerings.util.Util;

import com.threerings.orth.data.MediaDesc;

import flash.events.ErrorEvent;

public class MediaDescContainer extends MediaContainer
{
    public function MediaDescContainer (desc: MediaDesc = null)
    {
        super(null);

        if (desc != null) {
            setMediaDesc(desc);
        }
    }

    /**
     * Set a new MediaDescriptor. Returns true if the descriptor really changed.
     */
    public function setMediaDesc (desc :MediaDesc) :Boolean
    {
        if (Util.equals(desc, _desc)) {
            return false;
        }

        _desc = desc;

        if (desc == null) {
            super.setMedia(null);
        } else if (desc is PathMediaDesc) {
            super.setMedia(PathMediaDesc(desc).getMediaPath());
        } else if (desc is ObjectMediaDesc) {
            super.setMediaObject(ObjectMediaDesc(desc).getMediaObject());
        } else {
            throw new Error("Unknown media type: " + desc);
        }
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

    override protected function handleError (event :ErrorEvent) : void
    {
        super.handleError(event);

        dispatchEvent(event);
    }

    /** Our Media descriptor. */
    protected var _desc :MediaDesc;
}
}
