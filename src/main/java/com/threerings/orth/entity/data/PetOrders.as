//
// $Id: $
package com.threerings.orth.entity.data
{
public class PetOrders
{
    /** Orders this pet to stay in the current room, binding them to this room so that they will be
     * automatically loaded when anyone comes into the room. */
    public static const ORDER_STAY :int = 1;

    /** Orders this pet to follow the caller (who must be its owner). Any existing "stay" binding
     * will not be modified. */
    public static const ORDER_FOLLOW :int = 2;

    /** Orders this pet to stop following the caller (who must be its owner). If the pet is bound
     * to a room, and that room is resolved, it will return to that room, otherwise it will be
     * unloaded. */
    public static const ORDER_GO_HOME :int = 3;

    /** Orders this pet to unbind from any room and unload itself. The pet's owner may issue this
     * order in any circumstance, alternatively a player with modification privileges on a room may
     * issue this order on any pet that is bound to that room. */
    public static const ORDER_SLEEP :int = 4;
}
}
