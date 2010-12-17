//
// $Id: Prefs.as 18850 2009-12-14 20:27:03Z ray $

package com.threerings.orth.client {

import flash.events.EventDispatcher;

import flash.media.SoundMixer;
import flash.media.SoundTransform;

import com.threerings.util.Config;
import com.threerings.util.NamedValueEvent;
import com.threerings.util.StringUtil;

/**
 * Dispatched when a preference is changed.
 * This is dispatched on the 'events' object.
 *
 * @eventType com.threerings.orth.client.Prefs.PREF_SET;
 */
[Event(name="ConfigValSet", type="com.threerings.util.NamedValueEvent")]

public class Prefs
{
    /** We're a static class, so events are dispatched here. */
    public static const events :EventDispatcher = new EventDispatcher();

    /**
     * The event type dispatched when a preference is set
     *
     * @eventType ConfigValSet
     */
    public static const PREF_SET :String = Config.CONFIG_VALUE_SET;

    public static const USERNAME :String = "username";
    public static const MACHINE_IDENT :String = "machIdent";

    /**
     * Set the build time. Return true if it's changed. Should only be done on non-embedded clients.
     */
    public static function setBuildTime (buildTime :String) :Boolean
    {
        var lastBuild :String = (_config.getValue("lastBuild", null) as String);
        if (lastBuild != buildTime) {
            _config.setValue("lastBuild", buildTime);
            return true;
        }
        return false;
    }

    public static function getUsername () :String
    {
        return (_config.getValue(USERNAME, "") as String);
    }

    public static function setUsername (username :String) :void
    {
        _config.setValue(USERNAME, username);
    }

    public static function getMachineIdent () :String
    {
        return (_config.getValue(MACHINE_IDENT, "") as String);
    }

    public static function setMachineIdent (ident :String) :void
    {
        _config.setValue(MACHINE_IDENT, ident);
    }

    /** The path of our config object. */
    protected static const CONFIG_PATH :String = "rsrc/config/orth";

    /** Our config object. */
    protected static var _config :Config = new Config(null);

    /**
    * A static initializer.
    */
    private static function staticInit () :void
    {
        // route events
        _config.addEventListener(Config.CONFIG_VALUE_SET, events.dispatchEvent);
    }

    staticInit();
}
}
