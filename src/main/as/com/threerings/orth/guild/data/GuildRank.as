//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

// GENERATED PREAMBLE START
package com.threerings.orth.guild.data {

import com.threerings.util.Enum;

// GENERATED PREAMBLE END

// GENERATED CLASSDECL START
public final class GuildRank extends Enum
{
// GENERATED CLASSDECL END

// GENERATED ENUM START
    public static const MEMBER :GuildRank = new GuildRank("MEMBER");
    public static const VETERAN :GuildRank = new GuildRank("VETERAN");
    public static const OFFICER :GuildRank = new GuildRank("OFFICER");
    finishedEnumerating(GuildRank);

    /**
     * Gets the values of the GuildRank enum.
     */
    public static function values () :Array
    {
        return Enum.values(GuildRank);
    }

    /**
     * Gets the GuildRank instance that corresponds to the specified string.
     * If no such value exists, an ArgumentError will be thrown.
     */
    public static function valueOf (name :String) :GuildRank
    {
        return Enum.valueOf(GuildRank, name) as GuildRank;
    }

    /** @private */
    public function GuildRank (name :String)
    {
        super(name);
    }
// GENERATED ENUM END
// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END
