package com.threerings.orth.scene.data;

public interface EntityMedia
{
    /**
     * Returns the path of the URL that references this media.
     */
    String getMediaPath ();

    /**
     * Returns the mime type of this media.
     */
    byte getMimeType ();
}