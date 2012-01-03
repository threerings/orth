//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.entity.data;

import com.threerings.orth.data.MediaDesc;
import com.threerings.orth.room.data.EntityIdent;

/**
 * A basic streamable implementation of {@link Avatar}.
 */
public class AvatarData extends EntityData
    implements Avatar
{
    public MediaDesc avatarMedia;
    public float scale;

    public AvatarData (String name, MediaDesc media, EntityIdent ident, MediaDesc avatarMedia,
        float scale)
    {
        super(name, media, ident);
        this.avatarMedia = avatarMedia;
        this.scale = scale;
    }

    @Override public MediaDesc getAvatarMedia ()
    {
        return avatarMedia;
    }

    @Override public float getScale ()
    {
        return scale;
    }
}
