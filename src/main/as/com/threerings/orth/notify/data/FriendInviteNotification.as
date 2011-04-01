// GENERATED PREAMBLE START
//
// $Id$

package com.threerings.orth.notify.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;
import com.threerings.orth.aether.data.PlayerName;
import com.threerings.orth.notify.data.Notification;
import com.threerings.util.Name;

// GENERATED PREAMBLE END
// GENERATED CLASSDECL START
public class FriendInviteNotification extends Notification
{
// GENERATED CLASSDECL END
// GENERATED STREAMING START
    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        _sender = ins.readObject(PlayerName);
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeObject(_sender);
    }

    protected var _sender :PlayerName;
// GENERATED STREAMING END

    /**
     * Gets the player that sent the invite.
     */
    override public function getSender () :Name
    {
        return _sender;
    }

    /**
     * Gets the player that sent the invite.
     */
    public function getPlayerSender () :PlayerName
    {
        return _sender;
    }

// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END
