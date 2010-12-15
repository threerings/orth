//
// $Id: AboutDialog.as 12951 2008-10-29 01:25:28Z ray $

package com.threerings.orth.client {
import com.threerings.orth.ui.FloatingPanel;

import flash.system.Capabilities;

import mx.controls.Text;

import com.threerings.flex.FlexUtil;

/**
 * Displays a simple "About Whirled" dialog.
 */
public class AboutDialog extends FloatingPanel
{
    public function AboutDialog (ctx :OrthContext)
    {
        super(ctx, Msgs.GENERAL.get("t.about"));
        showCloseButton = true;
        open(false);
    }

    override protected function createChildren () :void
    {
        super.createChildren();

        var textArea :Text = FlexUtil.createText(null, 300);
        textArea.htmlText = Msgs.GENERAL.get("m.about", _ctx.getVersion(),
            Capabilities.version + (Capabilities.isDebugger ? " (debug)" : ""));
        addChild(textArea);

        addButtons(OK_BUTTON);
    }
}
}
