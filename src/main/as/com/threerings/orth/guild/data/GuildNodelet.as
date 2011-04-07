// GENERATED PREAMBLE START
//
// $Id$


package com.threerings.orth.guild.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;
import com.threerings.orth.nodelet.data.Nodelet;
// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class GuildNodelet extends Nodelet
{
// GENERATED CLASSDECL END

// GENERATED STREAMING START
    public var guildId :int;

    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        guildId = ins.readInt();
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeInt(guildId);
    }

// GENERATED STREAMING END

// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END

