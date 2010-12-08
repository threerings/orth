//
// $Id: AuthName.as 15765 2009-03-30 20:53:36Z ray $

package com.threerings.orth.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;
import com.threerings.util.ClassUtil;
import com.threerings.util.Name;

/**
 * Represents the authentication username for services that derive from orth.
 */
public class AuthName extends Name
{
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

    // from interface Streamable
    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        _id = ins.readInt();
    }

    // from interface Streamable
    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeInt(_id);
    }

    protected var _id :int;
}
}
