//
// $Id: $
package com.threerings.orth.client {
import flashx.funk.ioc.IModule;
import flashx.funk.ioc.inject;

import com.threerings.util.Controller;
import com.threerings.util.Log;

import com.threerings.orth.aether.client.AetherClient;
import com.threerings.orth.aether.data.AetherCredentials;
import com.threerings.orth.client.OrthDeploymentConfig;
import com.threerings.orth.client.TopPanel;

public class OrthController extends Controller
{
    /** Command to show the 'about' dialog. */
    public static const ABOUT :String = "About";

    /** Command to log us on. */
    public static const LOGON :String = "Logon";

    /** Command to display sign-up info for guests (TODO: not implemented). */
    public static const SHOW_SIGN_UP :String = "ShowSignUp";

    /** Command to show an (external) URL. */
    public static const VIEW_URL :String = "ViewUrl";

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

    /**
     * Convenience method for opening an external window and showing the specified url. This is
     * done when we want to show the user something without unloading the client.
     *
     * Also, handles VIEW_URL.
     *
     * @param url The url to show
     * @param windowOrTab the identifier of the tab to use, like _top or _blank, or null to
     * use the default, which is the same as _blank, I think. :)
     *
     * @return true on success
     */
    public function handleViewUrl (url :String, windowOrTab :String = null) :Boolean
    {
        // if our page refers to a Whirled page...
        if (NetUtil.navigateToURL(url, windowOrTab)) {
            return true;
        }

        _wctx.displayFeedback(
            OrthCodes.GENERAL_MSGS, MessageBundle.tcompose("e.no_navigate", url));

        // TODO
        // experimental: display a popup with the URL (this could be moved to handleLink()
        // if this method is altered to return a success Boolean
        new MissedURLDialog(_wctx, url);
        return false;
    }

    protected const _mod :IModule = inject(IModule);
    protected const _topPanel :TopPanel = inject(TopPanel);
    protected const _client :AetherClient = inject(AetherClient);
    protected const _depCon :OrthDeploymentConfig = inject(OrthDeploymentConfig);

    protected static var log :Log = Log.getLog(OrthController);
}
}
