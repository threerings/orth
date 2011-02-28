//
// $Id: EntranceFurniData.as 14149 2008-12-31 18:13:55Z mdb $

package com.threerings.orth.room.client.editor {

import com.threerings.msoy.item.data.all.Item;
import com.threerings.msoy.item.data.all.ItemIdent;
import com.threerings.orth.room.data.FurniData;

/**
 * This class is a version of furni data used by "fake" entrance furnis. It's only used to
 * differentiate entrances from other furnis; it provides no new functionality.
 */
public class EntranceFurniData extends FurniData
{
    public static const ENTRANCE_FURNI_ID :int = -1;
    public static const ITEM_IDENT :ItemIdent =
        new ItemIdent(Item.NOT_A_TYPE, ENTRANCE_FURNI_ID);

    public function EntranceFurniData ()
    {
        super();
        this.itemType = ITEM_IDENT.type;
        this.itemId = ITEM_IDENT.itemId;
    }

    // @Override from FurniData
    override public function toString () :String
    {
        return "Entrance" + super.toString();
    }
}
}
