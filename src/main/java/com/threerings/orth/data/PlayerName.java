//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.data;

import java.util.Comparator;

import com.google.common.primitives.Ints;

import com.threerings.util.Name;

import com.threerings.presents.dobj.DSet;

/**
 * Extends {link Name} with a unique identifier useful for persistence.
 *
 * <p> GWT NOTE: this class (and all {@link Name} derivatives} must use custom field serializers
 * because IsSerializable only serializes the fields in the class that declares that interface and
 * all subclasses, it does not serialize fields from the superclass. In this case, we have fields
 * from our superclass that need to be serialized, but we can't make {@link Name} implement
 * IsSerializable without introducing an otherwise unwanted dependency on GWT in Narya.
 *
 * <p> If you extend this class (or if you extend {@link Name}) you will have to implement a custom
 * field serializer for your derived class.
 */
public class PlayerName extends Name implements DSet.Entry
{
    /** A comparator for sorting Names by their display portion, case insensitively. */
    public static final Comparator<PlayerName> BY_DISPLAY_NAME = new Comparator<PlayerName>() {
        public int compare (PlayerName name1, PlayerName name2) {
            return compareNames(name1, name2);
        }
    };

    /**
     * Compares two member name records case insensitively.
     */
    public static int compareNames (PlayerName m1, PlayerName m2)
    {
        return m1.toString().toLowerCase().compareTo(m2.toString().toLowerCase());
    }

    /** Create a new PlayerName with the given display name and id. */
    public PlayerName (String name, int id)
    {
        super(name);
        _id = id;
    }

    /**
     * Return the id of this user.
     */
    public int getId ()
    {
        return _id;
    }

    public Comparable<?> getKey ()
    {
        return _id;
    }

    @Override // from Name
    public int hashCode ()
    {
        return _id;
    }

    @Override // from Name
    public boolean equals (Object other)
    {
        return (other instanceof PlayerName) && (((PlayerName) other).getId() == _id);
    }

    @Override // from Name
    public int compareTo (Name o)
    {
        // Note: You may be tempted to have names sort by the String value, but Names are used
        // as DSet keys in various places and so each user's must be unique.
        // Use BY_DISPLAY_NAME to sort names for display.
        return Ints.compare(_id, ((PlayerName) o).getId());
    }

    /** The member id of the member we represent. */
    protected int _id;
}
