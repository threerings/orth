//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.ui {

import flash.events.ErrorEvent;
import flash.events.Event;

import com.threerings.util.Util;

import com.threerings.media.MediaContainer;

import com.threerings.orth.data.MediaDesc;

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

            // dispatch an artificial COMPLETE event; should really be in MediaContainer
            dispatchEvent(new Event(Event.COMPLETE));
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
