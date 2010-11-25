//
// $Id: ActorInfo.java 16914 2009-05-27 05:54:19Z mdb $

package com.threerings.orth.scene.data {

import com.threerings.io.Streamable;
import com.threerings.util.ByteEnum;

public class FurniAction extends ByteEnum
{
    public function FurniAction (name :String, code :int)
    {
        super(name, code);
    }

    public function isPortal () :Boolean {
        throw new Error("abstract");
    }

    public function isURL () :Boolean {
        throw new Error("abstract");
    }
}
}
