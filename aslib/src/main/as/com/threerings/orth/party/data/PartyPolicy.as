//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

// GENERATED PREAMBLE START
package com.threerings.orth.party.data {

import com.threerings.util.Enum;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public final class PartyPolicy extends Enum
{
// GENERATED CLASSDECL END

// GENERATED ENUM START
    public static const OPEN :PartyPolicy = new PartyPolicy("OPEN");
    public static const FRIENDS :PartyPolicy = new PartyPolicy("FRIENDS");
    public static const CLOSED :PartyPolicy = new PartyPolicy("CLOSED");
    finishedEnumerating(PartyPolicy);

    /**
     * Gets the values of the PartyPolicy enum.
     */
    public static function values () :Array
    {
        return Enum.values(PartyPolicy);
    }

    /**
     * Gets the PartyPolicy instance that corresponds to the specified string.
     * If no such value exists, an ArgumentError will be thrown.
     */
    public static function valueOf (name :String) :PartyPolicy
    {
        return Enum.valueOf(PartyPolicy, name) as PartyPolicy;
    }

    /** @private */
    public function PartyPolicy (name :String)
    {
        super(name);
    }
// GENERATED ENUM END
// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END
