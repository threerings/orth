//
// $Id: UberClient.as 17120 2009-06-05 17:04:09Z zell $

package com.threerings.orth.client {

import com.threerings.orth.world.client.WorldClient;

import flash.display.DisplayObject;

import flash.system.Security;

import mx.core.Application;

import com.threerings.flex.FlexUtil;

import com.threerings.orth.data.UberClientModes;

/**
 * Assists in the usage of the UberClient.
 * This could just be part of world.mxml, but I don't like having a bunch of code
 * inside a CDATA block.
 */
public class UberClient
{
    /**
     * Convenience method: Are we running in a regular damn client?
     */
    public static function isRegularClient () :Boolean
    {
        return (UberClientModes.CLIENT == getMode());
    }

    /**
     * Are we a viewer of some sort, and not a client into the whirled servers?
     */
    public static function isViewer () :Boolean
    {
        switch (getMode()) {
        case UberClientModes.AVATAR_VIEWER:
        case UberClientModes.PET_VIEWER:
        case UberClientModes.DECOR_VIEWER:
        case UberClientModes.FURNI_VIEWER:
        case UberClientModes.TOY_VIEWER:
        case UberClientModes.DECOR_EDITOR:
        case UberClientModes.GENERIC_VIEWER:
            return true;

        default:
            return false;
        }
    }

    /**
     * Get the client mode. Only valid after initialization.
     */
    public static function getMode () :int
    {
        return _mode;
    }

    /**
     * Get the Application, which is not necessarily the same as
     * Application.application if we've been loaded into another app (like the remixer).
     */
    public static function getApplication () :Application
    {
        return _app;
    }

    // NOTE: The mode constants are defined in UberClientModes, so that users of that
    // class do not also need to include this class, which will drag in all the world client
    // classes.

    public static function init (app :Application) :void
    {
        var mode :int;
        var params :Object = MsoyParameters.get();

        // determine how this app should be configured!
        var d :DisplayObject = app;
        while (d != null) {
            if (d is UberClientLoader) {
                var ucl :UberClientLoader = d as UberClientLoader;

                mode = ucl.getMode();

                // stash the width/height in our real params
                params.width = ucl.width;
                params.height = ucl.height;

                setMode(app, mode, params);
                return;
            }
            try {
                d = d.parent;
            } catch (err :SecurityError) {
                d = null;
            }
        }

        if ("mode" in params) {
            // if a mode is specified, that overrides all
            mode = parseInt(params["mode"]);
        } else if ("avatar" in params) {
            mode = UberClientModes.AVATAR_VIEWER;
        } else if ("media" in params) {
            mode = UberClientModes.GENERIC_VIEWER;
        } else {
            mode = UberClientModes.CLIENT;
        }
        setMode(app, mode, params);
    }

    /**
     * Effects the setting of the mode and final setup of the client.
     */
    protected static function setMode (app :Application, mode :int, params :Object = null) :void
    {
        _app = app;
        _mode = mode;

        // Stash the mode back into the real parameters, in case we figured it out
        // somehow else.
        if (params != null) {
            params.mode = mode;
        }

        // Do not let a regular client be launched from the filesystem, it's probably
        // actually a booch with reading parameters (and probably on fucking windows).
        if (!isViewer() && (Security.sandboxType == Security.LOCAL_WITH_FILE)) {
            // do not load the world! Instead complain about being unable to read parameters.
            app.addChild(FlexUtil.createLabel("There was a problem starting the viewer."));
            return;
        }

        switch (mode) {
        default:
            new WorldClient(app.stage);
            break;

        case UberClientModes.STUB:
            setMode(app, UberClientModes.CLIENT, params);
            break;

        case UberClientModes.GENERIC_VIEWER:
            Object(app).setViewerObject(new Viewer(params));
            break;
        }
    }

    protected static var _app :Application;

    /** The mode, once we've figured it out. */
    protected static var _mode :int;
}
}
