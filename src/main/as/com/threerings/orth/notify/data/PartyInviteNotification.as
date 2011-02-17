// GENERATED PREAMBLE START
//
// $Id$

package com.threerings.orth.notify.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

import com.threerings.orth.aether.data.PlayerName;
import com.threerings.orth.notify.data.Notification;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class PartyInviteNotification extends Notification
{
// GENERATED CLASSDECL END

// GENERATED STREAMING START
    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        _inviter = ins.readObject(PlayerName);
        _partyId = ins.readInt();
        _partyName = ins.readField(String);
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeObject(_inviter);
        out.writeInt(_partyId);
        out.writeField(_partyName);
    }

    protected var _inviter :PlayerName;
    protected var _partyId :int;
    protected var _partyName :String;
// GENERATED STREAMING END

// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END

