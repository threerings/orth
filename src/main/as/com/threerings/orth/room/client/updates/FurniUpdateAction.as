//
// $Id: FurniUpdateAction.as 11811 2008-09-18 01:27:51Z mdb $

package com.threerings.orth.room.client.updates {

import com.threerings.whirled.data.SceneUpdate;

import com.threerings.orth.room.client.RoomContext;
import com.threerings.orth.room.data.FurniData;
import com.threerings.orth.room.data.FurniUpdate;
import com.threerings.orth.room.data.FurniUpdate_Add;
import com.threerings.orth.room.data.FurniUpdate_Change;
import com.threerings.orth.room.data.FurniUpdate_Remove;

/**
 * Generates a command to update a single piece of furni.
 */
public class FurniUpdateAction
    implements UpdateAction
{
    /** Create a new furni update command. */
    public function FurniUpdateAction (ctx :RoomContext, oldData :FurniData, newData :FurniData)
    {
        _ctx = ctx;
        _oldData = oldData;
        _newData = newData;
    }

    // documentation inherited from
    public function makeApply () :SceneUpdate
    {
        return makeUpdate(_oldData, _newData);
    }

    // documentation inherited
    public function makeUndo () :SceneUpdate
    {
        return makeUpdate(_newData, _oldData);
    }

    /**
     * Makes an update to send to the server. /toRemove/ will be removed, and /toAdd/ added.
     */
    protected function makeUpdate (toRemove :FurniData, toAdd :FurniData) :SceneUpdate
    {
        var furniUpdate :FurniUpdate = null;
        if (toAdd != null) {
            if (toRemove != null) {
                furniUpdate = new FurniUpdate_Change();
            } else {
                furniUpdate = new FurniUpdate_Add();
            }
            furniUpdate.data = toAdd;
        } else if (toRemove != null) {
            furniUpdate = new FurniUpdate_Remove();
            furniUpdate.data = toRemove;
        }
        return furniUpdate;
    }

    protected var _ctx :RoomContext;
    protected var _oldData :FurniData;
    protected var _newData :FurniData;
}
}
