//
// $Id: UrlDialog.as 14724 2009-02-09 00:56:09Z ray $

package com.threerings.orth.room.client.editor {

import mx.controls.Label;
import mx.controls.TextInput;

import com.threerings.orth.client.Msgs;
import com.threerings.orth.client.RoomContext;
import com.threerings.orth.room.client.editor.ui.FloatingPanel;

/**
 * Displays an "Enter the address:" dialog
 */
public class UrlDialog extends FloatingPanel
{
    public function UrlDialog (ctx :RoomContext, callback :Function)
    {
        super(ctx, Msgs.EDITING.get("t.url_dialog"));

        _callback = callback;
        open(true);
    }

    override protected function okButtonClicked () :void
    {
        _callback(_url.text, _tip.text);
    }

    override protected function createChildren () :void
    {
        super.createChildren();

        var label :Label = new Label();
        label.text = Msgs.EDITING.get("l.enter_url");
        addChild(label);

        _url = new TextInput();
        _url.text = "http://www.threerings.net/";
        _url.percentWidth = 100;
        _url.maxWidth = 300;
        addChild(_url);

        label = new Label();
        label.text = Msgs.EDITING.get("l.urlTip");
        addChild(label);

        _tip = new TextInput();
        _tip.percentWidth = 100;
        _tip.maxWidth = 300;
        addChild(_tip);

        addButtons(OK_BUTTON, CANCEL_BUTTON);
    }

    protected var _callback :Function;
    protected var _url :TextInput;
    protected var _tip :TextInput;
}
}
