//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.locus.client
{
import com.threerings.orth.locus.data.Locus;

/**
 * The locus observer interface makes it possible for entities to be notified when the client
 * moves to a new locus. It also provides a means for an entity to participate in the ratification
 * process of a new locus. Observers may opt to reject a request to change to a new locus, probably
 * because something is going on in the previous locus that should not be abandoned.
 */
public interface LocusObserver
{
    /**
     * Called when someone has requested that we switch to a new locus.
     */
    function locusWillChange (locus :Locus) :void;

    /**
     * Called when we have switched to a new locus. Note: this only means the materialization
     * stage has completed and {@link LocusContext#go} has been called. Beyond that, there is
     * typically an implementation-specific process by which the player actually ends up in a
     * place.
     *
     * An alternate observation approach might be through {@OrthPlaceBox}.
     *
     * @param place the place object that represents the new locus or null if we have switched to
     * no locus.
     */
    function locusDidChange (locus :Locus) :void;

    /**
     * This is called on all locus observers when a locus change request is rejected by the server
     * or fails for some other reason.
     *
     * @param placeId the place id to which we attempted to relocate, but failed.
     * @param reason the reason code that explains why the locus change request was rejected or
     * otherwise failed.
     */
    function locusChangeFailed (locus :Locus, reason :String) :void;
}
}
