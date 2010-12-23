//
// $Id: AboutDialog.as 12951 2008-10-29 01:25:28Z ray $

package com.threerings.orth.client {

import flash.system.Capabilities;

import mx.controls.Text;

import com.threerings.flex.FlexUtil;

import com.threerings.orth.client.OrthDeploymentConfig;
import com.threerings.orth.ui.FloatingPanel;

/**
 * Displays a simple "About ..." dialog.
 */
public class AboutDialog extends FloatingPanel
{
    public function AboutDialog ()
    {
        super(Msgs.GENERAL.get("t.about"));
        showCloseButton = true;
        open(false);
    }

    override protected function createChildren () :void
    {
        super.createChildren();

        var textArea :Text = FlexUtil.createText(null, 300);
        textArea.htmlText = Msgs.GENERAL.get("m.about", _depcon.getVersion(),
            Capabilities.version + (Capabilities.isDebugger ? " (debug)" : ""));
        addChild(textArea);

        addButtons(OK_BUTTON);
    }

    [Inject] public var _depcon :OrthDeploymentConfig;
}
}
