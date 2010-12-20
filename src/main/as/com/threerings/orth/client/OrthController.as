//
// $Id: $
package com.threerings.orth.client
{
import com.threerings.util.Controller;
import com.threerings.util.Log;

import com.threerings.orth.aether.data.AetherCredentials;

public class OrthController extends Controller
{
    /** Command to show the 'about' dialog. */
    public static const ABOUT :String = "About";

    /** Command to log us on. */
    public static const LOGON :String = "Logon";

    /** Command to display sign-up info for guests (TODO: not implemented). */
    public static const SHOW_SIGN_UP :String = "ShowSignUp";

    public function OrthController (octx :OrthContext, topPanel :TopPanel)
    {
        _octx = octx;

        setControlledPanel(topPanel);
    }

    /**
     * Handles the ABOUT command.
     */
    public function handleAbout () :void
    {
        new AboutDialog(_octx);
    }

    /**
     * Handles the LOGON command.
     */
    public function handleLogon (creds :AetherCredentials) :void
    {
        // give the client a chance to log off, then log back on
        _octx.topPanel.callLater(function () :void {
            log.info("Logging on", "creds", creds, "version", _octx.deployment.getVersion());
            _octx.client.logonWithCredentials(creds);
        });
    }

    protected var _octx :OrthContext;

    protected static var log :Log = Log.getLog(OrthController);
}
}
