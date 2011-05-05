//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.
package com.threerings.orth.entity.data {

import flash.geom.Point;

import flashx.funk.util.isAbstract;

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;
import com.threerings.io.Streamable;

// GENERATED PREAMBLE END
// GENERATED CLASSDECL START
public class Walkability implements Streamable
{
// GENERATED CLASSDECL END

    public function isPathWalkable (from :Point, to :Point) :Boolean
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
