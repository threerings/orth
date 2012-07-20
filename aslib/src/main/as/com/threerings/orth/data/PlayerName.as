//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

// GENERATED PREAMBLE START
package com.threerings.orth.data {

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

import com.threerings.util.Comparators;
import com.threerings.util.Integer;
import com.threerings.util.Name;

import com.threerings.presents.dobj.DSet_Entry;

import com.threerings.orth.data.PlayerName;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public class PlayerName extends Name
    implements DSet_Entry
{
// GENERATED CLASSDECL END
    /** A sort function for sorting Names by their display portion, case insensitively.  */
    public static const BY_DISPLAY_NAME :Function = function (n1 :Name, n2 :Name) :int {
        return Comparators.compareStringsInsensitively(n1.toString(), n2.toString());
    };

    public function PlayerName (displayName :String = "", memberId :int = 0)
    {
        super(displayName);
        _id = memberId;
    }

    /**
     * Return the memberId of this user, or 0 if they're a guest.
     */
    public function get id () :int
    {
        return _id;
    }

    // from DSet_Entry
    public function getKey () :Object
    {
        return _id;
    }

    // from Name
    override public function hashCode () :int
    {
        return _id;
    }

    // from Name
    override public function compareTo (o :Object) :int
    {
        // Note: You may be tempted to have names sort by the String value, but Names are used
        // as DSet keys in various places and so each user's must be unique.
        // Use BY_DISPLAY_NAME to sort names for display.
        return Integer.compare(_id, (o as PlayerName)._id);
    }

    // from Name
    override public function equals (other :Object) :Boolean
    {
        return (other is PlayerName) && ((other as PlayerName)._id == _id);
    }

    // from Name
    override protected function normalize (name :String) :String
    {
        return name; // do not adjust
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

