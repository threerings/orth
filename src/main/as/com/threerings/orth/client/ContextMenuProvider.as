//
// $Id: ContextMenuProvider.as 8847 2008-04-15 17:18:01Z nathan $

package com.threerings.orth.client {

import com.threerings.orth.world.client.WorldContext;

/**
 * An interface that should be implemented by DisplayObjects that wish
 * to add custom menu items to the context menu.
 */
public interface ContextMenuProvider
{
    /**
     * Called to add to the array of custom menu items.
     */
    function populateContextMenu (ctx :WorldContext, menuItems :Array) :void;
}
}
