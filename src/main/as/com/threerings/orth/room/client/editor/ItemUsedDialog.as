//
// $Id: ItemUsedDialog.as 14724 2009-02-09 00:56:09Z ray $

package com.threerings.orth.room.client.editor {

import com.threerings.flex.FlexUtil;

import com.threerings.orth.client.Msgs;
import com.threerings.orth.room.client.editor.ui.FloatingPanel;

public class ItemUsedDialog extends FloatingPanel
{
    public function ItemUsedDialog (type :String, yesClosure :Function)
    {
        super(Msgs.EDITING.get("t.item_used"));
        _yesClosure = yesClosure;
        addChild(FlexUtil.createText(Msgs.EDITING.get("m.item_used", type), 250));
    }

    override protected function createChildren () :void
    {
        super.createChildren();
        addButtons(OK_BUTTON, CANCEL_BUTTON);
    }

    override protected function getButtonLabel (buttonId :int) :String
    {
        switch (buttonId) {
        case CANCEL_BUTTON: return Msgs.EDITING.get("b.no");
        case OK_BUTTON: return Msgs.EDITING.get("b.yes");
        default: return super.getButtonLabel(buttonId)
        }
    }

    override protected function okButtonClicked () :void
    {
        _yesClosure();
    }

    protected var _yesClosure :Function;
}
}
