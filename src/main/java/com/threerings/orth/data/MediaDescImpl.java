package com.threerings.orth.data;

import com.threerings.io.Streamable;

import com.threerings.orth.data.MediaDesc;

import com.google.gwt.user.client.rpc.IsSerializable;

public abstract class MediaDescImpl
    implements MediaDesc, IsSerializable, Streamable
{
    /** Used for deserialization. */
    public MediaDescImpl ()
    {
    }

    public abstract byte getMimeType ();
    public abstract byte getConstraint ();

    public boolean isImage ()
    {
        return MediaMimeTypes.isImage(getMimeType());
    }

    public boolean isSWF ()
    {
        return (getMimeType() == MediaMimeTypes.APPLICATION_SHOCKWAVE_FLASH);
    }

    public boolean isAudio ()
    {
        return MediaMimeTypes.isAudio(getMimeType());
    }

    public boolean isVideo ()
    {
        return MediaMimeTypes.isVideo(getMimeType());
    }

    public boolean hasFlashVisual ()
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

    @Override // from Object
    public int hashCode ()
    {
        return (getMimeType() * 43) + getConstraint();
    }

	@Override // from Object
	public boolean equals (Object other)
	{
		return (other instanceof MediaDesc) &&
			(getMimeType() == ((MediaDesc) other).getMimeType()) &&
            (getConstraint() == ((MediaDesc) other).getConstraint());

	}
}
