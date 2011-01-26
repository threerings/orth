// GENERATED PREAMBLE START
//
// $Id$

package com.threerings.orth.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

// GENERATED PREAMBLE END

import com.threerings.util.ClassUtil;
import com.threerings.util.Name;

/**
 * Represents the authentication username for services that derive from orth.
 */
// GENERATED CLASSDECL START
public class AuthName extends Name
{
// GENERATED CLASSDECL END

    /** Used for unserializing. We never create these directly in Flash. */
    public function AuthName ()
    {
    }

    /** Returns this member's unique id. */
    public function getId () :int
    {
        return _id;
    }

    // from Name
    override public function hashCode () :int
    {
        return _id;
    }

    // from Name
    override public function equals (other :Object) :Boolean
    {
        return (other != null) && ClassUtil.isSameClass(this, other) &&
            (AuthName(other).getId() == getId());
    }

// GENERATED STREAMING START
    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        _id = ins.readInt();
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeInt(_id);
    }

    protected var _id :int;
// GENERATED STREAMING END

// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END
