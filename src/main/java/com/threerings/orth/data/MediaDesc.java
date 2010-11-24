//
// $Id: $

package com.threerings.orth.data;

import com.threerings.orth.scene.data.EntityMedia;

public interface MediaDesc
{
    /** A constant used to indicate that an image does not exceed half thumbnail size in either
     * dimension. */
    byte NOT_CONSTRAINED = 0;

    /** A constant used to indicate that an image exceeds thumbnail size proportionally more in the
     * horizontal dimension. */
    byte HORIZONTALLY_CONSTRAINED = 1;

    /** A constant used to indicate that an image exceeds thumbnail size proportionally more in the
     * vertical dimension. */
    byte VERTICALLY_CONSTRAINED = 2;

    /** A constant used to indicate that an image exceeds half thumbnail size proportionally more
     * in the horizontal dimension but does not exceed thumbnail size in either dimension. */
    byte HALF_HORIZONTALLY_CONSTRAINED = 3;

    /** A constant used to indicate that an image exceeds half thumbnail size proportionally more
     * in the vertical dimension but does not exceed thumbnail size in either dimension. */
    byte HALF_VERTICALLY_CONSTRAINED = 4;

    /**
     * Returns the path of the URL that references this media.
     */
    String getMediaPath ();

    /**
     * Returns the mime type of this media.
     */
    byte getMimeType ();
    
    /** The size constraint on this media, if any. See {@link #computeConstraint}. */
    byte getConstraint ();

    /** Create and return a new MediaDesc, identical except with the new constraint. */
    MediaDesc newWithConstraint (byte constraint);

    /**
     * Is this media merely an image type?
     */
    boolean isImage ();

    /**
     * Is this media a SWF?
     */
    boolean isSWF ();

    /**
     * Is this media purely audio?
     */
    boolean isAudio ();

    /**
     * Is this media video?
     */
    boolean isVideo ();

    boolean isExternal ();

    /**
     * Return true if this media has a visual component that can be shown in
     * flash.
     */
    boolean hasFlashVisual ();

    /**
     * Is this a zip of some sort?
     */
    boolean isRemixed ();

    /**
     * Is this media remixable?
     */
    boolean isRemixable ();

    /**
     * Returns the path of the URL that loads this media proxied through our game server so that we
     * can work around Java applet sandbox restrictions. Subclasses may override this.
     */
    String getProxyMediaPath ();
}
