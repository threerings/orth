//
// $Id: $
package com.threerings.orth.client {

import org.swiftsuspenders.Injector;

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

    [PostConstruct]
    public function initOrthController () :void
    {
        setControlledPanel(_topPanel);
    }

    /**
     * Handles the ABOUT command.
     */
    public function handleAbout () :void
    {
        _injector.getInstance(AboutDialog);
    }

    /**
     * Handles the LOGON command.
     */
    public function handleLogon (creds :AetherCredentials) :void
    {
        // give the client a chance to log off, then log back on
        _topPanel.callLater(function () :void {
            log.info("Logging on", "creds", creds, "version", _depCon.getVersion());
            _client.logonWithCredentials(creds);
        });
    }

    [Inject] public var _injector :Injector;
    [Inject] public var _topPanel :TopPanel;
    [Inject] public var _client :AetherClient;
    [Inject] public var _depCon :OrthDeploymentConfig;

    protected static var log :Log = Log.getLog(OrthController);
}
}
