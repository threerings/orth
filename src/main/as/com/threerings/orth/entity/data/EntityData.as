// GENERATED PREAMBLE START
//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.


package com.threerings.orth.entity.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;
import com.threerings.io.SimpleStreamableObject;

import com.threerings.orth.data.MediaDesc;
import com.threerings.orth.entity.data.Entity;
import com.threerings.orth.room.data.EntityIdent;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class EntityData extends SimpleStreamableObject
    implements Entity
{
// GENERATED CLASSDECL END

// GENERATED STREAMING START
    public var name :String;

    public var media :MediaDesc;

    public var ident :EntityIdent;

    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        name = ins.readField(String);
        media = ins.readObject(MediaDesc);
        ident = ins.readObject(EntityIdent);
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeField(name);
        out.writeObject(media);
        out.writeObject(ident);
    }

// GENERATED STREAMING END

    // from Entity
    public function getName () :String
    {
        return name;
    }

    // from Entity
    public function getIdent () :EntityIdent
    {
        return ident;
    }

    // from Entity
    public function getThumbnailMedia () :MediaDesc
    {
        // ORTH TODO: Only used in a single place, in {@link RoomObjectController}, nuke?
        return null;
    }

    // from Entity
    public function getFurniMedia () :MediaDesc
    {
        return media;
    }

    // from Comparable
    public function compareTo (other :Object) :int
    {
        return ident.compareTo(Entity(other).getIdent());
    }

    public function equals (other :Object) :Boolean
    {
        return ident.equals(other.ident);
    }

    public function hashCode () :int
    {
        return ident.hashCode();
    }

    public function getKey () :Object
    {
        return ident;
    }

// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END

