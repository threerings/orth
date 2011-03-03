// GENERATED PREAMBLE START
//
// $Id$

package com.threerings.orth.data {

import flashx.funk.util.isAbstract;

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;
import com.threerings.io.Streamable;

import com.threerings.orth.data.MediaDesc;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class MediaDescImpl implements MediaDesc, Streamable
{
// GENERATED CLASSDECL END
    public function getMimeType () :int
    {
        return isAbstract();
    }

    public function getConstraint () :int
    {
        return isAbstract();
    }

    public function get mimeType () :int
    {
        return isAbstract();
    }

    public function get constraint () :int
    {
        return isAbstract();
    }

    public function isImage () :Boolean
    {
        return MediaMimeTypes.isImage(getMimeType());
    }

    public function isSWF () :Boolean
    {
        return (getMimeType() == MediaMimeTypes.APPLICATION_SHOCKWAVE_FLASH);
    }

    public function isAudio () :Boolean
    {
        return MediaMimeTypes.isAudio(getMimeType());
    }

    public function isVideo () :Boolean
    {
        return MediaMimeTypes.isVideo(getMimeType());
    }

    public function hasFlashVisual () :Boolean
    {
        switch (getMimeType()) {
        case MediaMimeTypes.IMAGE_PNG:
        case MediaMimeTypes.IMAGE_JPEG:
        case MediaMimeTypes.IMAGE_GIF:
        case MediaMimeTypes.VIDEO_FLASH:
        case MediaMimeTypes.EXTERNAL_YOUTUBE:
        case MediaMimeTypes.APPLICATION_SHOCKWAVE_FLASH:
            return true;

        default:
            return false;
        }
    }

    public function equals (other :Object) :Boolean
    {
        return isAbstract();
    }

// GENERATED STREAMING START
    public function readObject (ins :ObjectInputStream) :void
    {
    }

    public function writeObject (out :ObjectOutputStream) :void
    {
    }

// GENERATED STREAMING END

// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END

