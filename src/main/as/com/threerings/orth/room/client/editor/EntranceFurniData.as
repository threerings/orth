//
// $Id: EntranceFurniData.as 14149 2008-12-31 18:13:55Z mdb $

package com.threerings.orth.room.client.editor {

import com.threerings.orth.room.data.EntityIdent;
import com.threerings.orth.room.data.EntityType;
import com.threerings.orth.room.data.FurniData;
import com.threerings.orth.room.data.SimpleEntityIdent;

/**
 * This class is a version of furni data used by "fake" entrance furnis. It's only used to
 * differentiate entrances from other furnis; it provides no new functionality.
 */
public class EntranceFurniData extends FurniData
{
    public static const ENTRANCE_FURNI_ID :int = -1;

    public function EntranceFurniData ()
    {
        super();
        this.item = new SimpleEntityIdent(EntityType.NOT_A_TYPE, ENTRANCE_FURNI_ID);

    }

    // @Override from FurniData
    override public function toString () :String
    {
        return "Entrance" + super.toString();
    }
}
}
