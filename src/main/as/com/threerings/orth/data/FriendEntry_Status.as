// GENERATED PREAMBLE START
//
// $Id$


package com.threerings.orth.data {

import com.threerings.util.Enum;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public final class FriendEntry_Status extends Enum
{
// GENERATED CLASSDECL END

// GENERATED ENUM START
    public static const OFFLINE :FriendEntry_Status = new FriendEntry_Status("OFFLINE");
    public static const ONLINE :FriendEntry_Status = new FriendEntry_Status("ONLINE");
    finishedEnumerating(FriendEntry_Status);

    /**
     * Gets the values of the FriendEntry_Status enum.
     */
    public static function values () :Array
    {
        return Enum.values(FriendEntry_Status);
    }

    /**
     * Gets the FriendEntry_Status instance that corresponds to the specified string.
     * If no such value exists, an ArgumentError will be thrown.
     */
    public static function valueOf (name :String) :FriendEntry_Status
    {
        return Enum.valueOf(FriendEntry_Status, name) as FriendEntry_Status;
    }

    /** @private */
    public function FriendEntry_Status (name :String)
    {
        super(name);
    }
// GENERATED ENUM END
// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END
