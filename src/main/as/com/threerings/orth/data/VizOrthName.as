//
// $Id: VizMemberName.as 19627 2010-11-24 16:02:41Z zell $

package com.threerings.orth.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

/**
 * Exetnds OrthName with a profile photo.
 */
public class VizOrthName extends OrthName
{
    /**
     * Returns this member's photo.
     */
    public function getPhoto () :MediaDesc
    {
        return _photo;
    }

    // from OccupantInfo
    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        _photo = MediaDesc(ins.readObject());
    }

    // from OccupantInfo
    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeObject(_photo);
    }

    /** This member's profile photo. */
    protected var _photo :MediaDesc;
}
}
