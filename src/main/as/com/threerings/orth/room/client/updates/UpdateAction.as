//
// $Id: UpdateAction.as 14149 2008-12-31 18:13:55Z mdb $

package com.threerings.orth.room.client.updates {

import com.threerings.whirled.data.SceneUpdate;

/**
 * Interface for individual room editing actions, which can be applied or undone.
 */
public interface UpdateAction
{
    /**
     * Creates a new scene update object, which applies this action to the room.
     */
    function makeApply () :SceneUpdate;

    /**
     * Creates a new scene update object, which reverts the effects of this action on the room.
     */
    function makeUndo () :SceneUpdate;

}
}