//
// $Id: $
package com.threerings.orth.client {
import flashx.funk.ioc.IModule;
import flashx.funk.ioc.inject;

import com.threerings.util.Controller;
import com.threerings.util.Log;

import com.threerings.orth.client.OrthDeploymentConfig;
import com.threerings.orth.client.TopPanel;

import com.threerings.orth.aether.client.AetherClient;
import com.threerings.orth.aether.data.AetherCredentials;

public class OrthController extends Controller
{
    /** Command to show the 'about' dialog. */
    public static const ABOUT :String = "About";

    /** Command to log us on. */
    public static const LOGON :String = "Logon";

    /** Command to display sign-up info for guests (TODO: not implemented). */
    public static const SHOW_SIGN_UP :String = "ShowSignUp";

    public function OrthController ()
    {
        setControlledPanel(_topPanel);
    }

    /**
     * Handles the ABOUT command.
     */
    public function handleAbout () :void
    {
        _mod.getInstance(AboutDialog);
    }

    /**
     * Handles the LOGON command.
     */
    public function handleLogon (creds :AetherCredentials) :void
    {
        // give the client a chance to log off, then log back on
        _topPanel.callLater(function () :void {
            log.info("Logging on", "creds", creds, "version", _depCon.version);
            _client.logonWithCredentials(creds);
        });
    }

    protected var _mod :IModule = inject(IModule);
    protected var _topPanel :TopPanel = inject(TopPanel);
    protected var _client :AetherClient = inject(AetherClient);
    protected var _depCon :OrthDeploymentConfig = inject(OrthDeploymentConfig);

    protected static var log :Log = Log.getLog(OrthController);
}
}
