//
// $Id: $


package com.threerings.orth.entity.data;

import com.threerings.orth.data.MediaDesc;

/**
 * A basic streamable implementation of {@link Avatar}.
 */
public class AvatarData extends EntityData
    implements Avatar
{
    public MediaDesc avatarMedia;
    public float scale;

    @Override public MediaDesc getAvatarMedia ()
    {
        return avatarMedia;
    }

    @Override public float getScale ()
    {
        return scale;
    }
}
