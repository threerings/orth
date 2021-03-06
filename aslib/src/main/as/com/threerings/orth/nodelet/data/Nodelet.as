//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

// GENERATED PREAMBLE START
package com.threerings.orth.nodelet.data {

import flash.utils.getQualifiedClassName;

import flashx.funk.util.isAbstract;

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;
import com.threerings.io.SimpleStreamableObject;

import com.threerings.util.Equalable;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class Nodelet extends SimpleStreamableObject
{
// GENERATED CLASSDECL END

// GENERATED STREAMING START
    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
    }

// GENERATED STREAMING END

    public function equals (other :Object) :Boolean
    {
        if (getQualifiedClassName(other) == getQualifiedClassName(this)) {
            var id :Object = getId();
            if (id is Equalable) {
                return Equalable(id).equals(Nodelet(other).getId());
            }
            return getId() == Nodelet(other).getId();
        }
        return false;
    }

    /**
     * Gets a unique key for this locus, used as a dset key.
     */
    public function getId () :Object
    {
        return isAbstract();
    }
// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END

