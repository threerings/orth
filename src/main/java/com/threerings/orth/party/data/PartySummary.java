//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.party.data;

import com.threerings.io.SimpleStreamableObject;

import com.threerings.orth.data.MediaDesc;
import com.threerings.presents.dobj.DSet;

/**
 * Contains a summary of immutable party information, published in node objects and copied
 * into any PartyPlaceObject that any partier joins.
 */
public class PartySummary extends SimpleStreamableObject
    implements DSet.Entry
{
    /** The party id. */
    public int id;

    /** The current name of the party. */
    public String name;

    /** The party's icon */
    public MediaDesc icon;

    /** Suitable for unserialization. */
    public PartySummary ()
    {
    }

    /** Create a PartySummary. */
    public PartySummary (int id, String name, MediaDesc icon)
    {
        this.id = id;
        this.name = name;
        this.icon = icon;
    }

    // from DSet.Entry
    public Comparable<?> getKey ()
    {
        return id;
    }
}
