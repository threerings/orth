//
// $Id: OrthName.as 17905 2009-08-24 21:05:57Z ray $

package com.threerings.orth.data {

import com.threerings.presents.dobj.DSet_Entry;

import com.threerings.util.Comparators;
import com.threerings.util.Integer;
import com.threerings.util.Name;

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

/**
 * Extends Name with persistent member information.
 */
public class OrthName extends Name
    implements DSet_Entry
{
    /** A sort function for sorting Names by their display portion, case insensitively.  */
    public static const BY_DISPLAY_NAME :Function = function (n1 :Name, n2 :Name) :int {
        return Comparators.compareStringsInsensitively(n1.toString(), n2.toString());
    };

    /**
     * Create a new OrthName.
     */
    public function OrthName (displayName :String = "", memberId :int = 0)
    {
        super(displayName);
        _id = memberId;
    }

    /**
     * Return the memberId of this user, or 0 if they're a guest.
     */
    public function getId () :int
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
        return Integer.compare(_id, (o as OrthName)._id);
    }

    // from Name
    override public function equals (other :Object) :Boolean
    {
        return (other is OrthName) && ((other as OrthName)._id == _id);
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

    // from Name
    override protected function normalize (name :String) :String
    {
        return name; // do not adjust
    }

    /** The member id of the member we represent. */
    protected var _id :int;
}
}
