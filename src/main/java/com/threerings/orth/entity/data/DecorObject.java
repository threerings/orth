//
// $Id$

package com.threerings.orth.entity.data;

import com.threerings.io.SimpleStreamableObject;
import com.threerings.orth.data.MediaDesc;
import com.threerings.orth.room.data.EntityIdent;
import com.threerings.orth.entity.data.Decor;
import com.threerings.orth.entity.data.Entity;

/**
 * A basic streamable implementation of {@link Decor}.
 */
public class DecorObject extends SimpleStreamableObject
    implements Decor
{
    public byte type;
    public MediaDesc media;
    public EntityIdent ident;
    public short width;
    public short height;
    public short depth;
    public float horizon;
    public float actorScale;
    public float furniScale;

    // from DSet.Entry
    public Comparable<?> getKey ()
    {
        return getIdent();
    }

    // from Comparable
    public int compareTo (Entity other) {
        // ORTH TODO: not at all sure we need Entity to be comparable
        return 0;
    }

    // from Entity
    public MediaDesc getFurniMedia () {
        return media;
    }

    // from Entity
    public MediaDesc getThumbnailMedia () {
        // ORTH TODO: not at all sure we need this
        return null;
    }

    // from Entity
    public EntityIdent getIdent () {
        return ident;
    }

    // from Decor
    public float getHorizon () {
        return horizon;
    }

    // from Decor
    public short getDepth () {
        return depth;
    }

    // from Decor
    public short getWidth () {
        return width;
    }

    // from Decor
    public short getHeight () {
        return height;
    }

    // from Decor
    public float getActorScale () {
        return actorScale;
    }

    // from Decor
    public float getFurniScale () {
        return furniScale;
    }

    // from Decor
    public byte getDecorType () {
        return type;
    }
}