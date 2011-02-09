// GENERATED PREAMBLE START
//
// $Id$

package com.threerings.orth.world.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;
import com.threerings.io.SimpleStreamableObject;

import com.threerings.util.Comparable;

// GENERATED PREAMBLE END
// GENERATED CLASSDECL START
public class PlaceKey extends SimpleStreamableObject
    implements Comparable
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

    /** A short, opaque string uniquely identifying what type of place this is. */
    public function getPlaceType () :String
    {
        throw new Error("abstract");
    }

    /** Returns the appropriate WorldModule subclass for this place. */
    public function getModuleClass () :Class
    {
        throw new Error("abstract");
    }

    public function compareTo (other:Object):int
    {
        // ORTH TODO: nothing on the AS client actually uses our Comparableness, but there's
        // no way for us to say we don't want the generated streamable not to be Comparable
        return 0;
    }

// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END
