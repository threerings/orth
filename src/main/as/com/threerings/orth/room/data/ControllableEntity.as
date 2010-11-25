//
// $Id: ControllableEntity.as 12486 2008-10-13 18:19:39Z jamie $

package com.threerings.orth.room.data {

import com.threerings.io.ObjectOutputStream;
import com.threerings.io.ObjectInputStream;

/**
 * A reference to a controllable entity.
 */
public class ControllableEntity extends Controllable
{
    public function ControllableEntity (ident :EntityIdent = null)
    {
        _ident = ident;
    }

    override public function equals (other :Object) :Boolean
    {
        return ((other is ControllableEntity) && _ident != null &&
                _ident.equals((other as ControllableEntity).getItemIdent()));
    }

    public function getItemIdent () :EntityIdent
    {
        return _ident;
    }

    // from interface Streamable
    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        _ident = EntityIdent(ins.readObject());
    }

    // from interface Streamable
    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeObject(_ident);
    }

    protected var _ident :EntityIdent;
}
}
