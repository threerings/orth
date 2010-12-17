//
// $Id$

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
    function populateContextMenu (ctx :OrthContext, menuItems :Array) :void;
}
}
