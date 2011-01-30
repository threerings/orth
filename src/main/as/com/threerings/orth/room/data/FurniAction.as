//
// $Id: ActorInfo.java 16914 2009-05-27 05:54:19Z mdb $

package com.threerings.orth.room.data {

import com.threerings.util.ByteEnum;

public class FurniAction extends ByteEnum
{
    public static const NONE :FurniAction = new FurniAction("NONE", 0);

    public function FurniAction (name :String, code :int)
    {
        super(name, code);
    }

    public function isPortal () :Boolean {
        return false;
    }

    public function isURL () :Boolean {
        return false;
    }

    public function isHelpPage () :Boolean {
        return true;
    }
}
}