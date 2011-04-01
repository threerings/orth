//
// $Id$

package com.threerings.orth.data;

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
     * Returns the mime type of this media.
     */
    byte getMimeType ();

    /** The size constraint on this media, if any. */
    byte getConstraint ();
}
