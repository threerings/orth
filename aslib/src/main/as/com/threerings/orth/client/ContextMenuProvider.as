//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.client {

/**
 * An interface that should be implemented by DisplayObjects that wish
 * to add custom menu items to the context menu.
 */
public interface ContextMenuProvider
{
    /**
     * Called to add to the array of custom menu items.
     */
    function populateContextMenu (menuItems :Array) :void;
}
}
