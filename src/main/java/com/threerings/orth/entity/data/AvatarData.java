//
// $Id: $


package com.threerings.orth.entity.data;

import com.threerings.orth.data.MediaDesc;

/**
 * A basic streamable implementation of {@link Avatar}.
 */
public class AvatarObject extends EntityObject
    implements Avatar
{
    public MediaDesc media;
    public float scale;

    @Override public MediaDesc getAvatarMedia ()
    {
        return media;
    }

    @Override public float getScale ()
    {
        return scale;
    }
}
