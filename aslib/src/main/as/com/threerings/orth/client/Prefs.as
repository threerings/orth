//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.client {
import flash.events.EventDispatcher;
import flash.media.SoundMixer;
import flash.media.SoundTransform;

import com.threerings.util.Config;
import com.threerings.util.Log;
import com.threerings.util.Preconditions;
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
    public static const SESSION_TOKEN :String = "sessionTok";
    public static const MACHINE_IDENT :String = "machIdent";
    public static const VOLUME :String = "volume";
    public static const PARTY_GROUP :String = "partyGroup";
    public static const AUTOSHOW_PREFIX :String = "autoShow_";
    public static const IGNORED_TUTORIAL_IDS :String = "ignoredTutIds";
    public static const TUTORIAL_PROGRESS_PREFIX :String = "tutProgress_";

    public static const APRIL_FOOLS :String = "aprilFools";

    /** List of cookies (that the user may see and clear). */
    public static const ALL_KEYS :Array = [
        VOLUME, PARTY_GROUP, IGNORED_TUTORIAL_IDS, TUTORIAL_PROGRESS_PREFIX,
        AUTOSHOW_PREFIX ];

    /**
     * Creates our backing Config object using path for persistent local storage. Must be called
     * before any other Prefs methods are called.
     */
    public static function init (path :String) :void
    {
        if (_config != null) {
            log.warning("Prefs.init called a second time. Ignoring.", "path", path, new Error());
            return;
        }
        _config = new Config(path);
        _config.addEventListener(Config.CONFIG_VALUE_SET, events.dispatchEvent);
        useSoundVolume();
    }

    public static function getUsername () :String
    {
        return (getConfig().getValue(USERNAME, "") as String);
    }

    public static function setUsername (username :String) :void
    {
        getConfig().setValue(USERNAME, username);
    }

    public static function getMachineIdent () :String
    {
        return (getConfig().getValue(MACHINE_IDENT, "") as String);
    }

    public static function setMachineIdent (ident :String) :void
    {
        getConfig().setValue(MACHINE_IDENT, ident);
    }

    public static function getSoundVolume () :Number
    {
        return (getConfig().getValue(VOLUME, 1) as Number);
    }

    public static function setSoundVolume (vol :Number) :void
    {
        getConfig().setValue(VOLUME, vol);
        useSoundVolume();
    }

    public static function getPartyGroup () :int
    {
        return (getConfig().getValue(PARTY_GROUP, 0) as int);
    }

    public static function setPartyGroup (groupId :int) :void
    {
        getConfig().setValue(PARTY_GROUP, groupId);
    }

    public static function isTutorialIgnored (id :String) :Boolean
    {
        return getIgnoredTutorialIds().contains(id);
    }

    public static function ignoreTutorial (id :String) :void
    {
        getIgnoredTutorialIds().update(id, true);
    }

    public static function getTutorialProgress (id :String) :int
    {
        return getConfig().getValue(TUTORIAL_PROGRESS_PREFIX + id, 0) as int;
    }

    public static function setTutorialProgress (id :String, progress :int) :void
    {
        getConfig().setValue(TUTORIAL_PROGRESS_PREFIX + id, progress);
    }

    /**
     * Returns whether the dialog of the given name should be shown automatically. The name is an
     * arbitrary string chosen by the caller to represent the dialog.
     */
    public static function getAutoshow (dialogName :String) :Boolean
    {
        return Boolean(getConfig().getValue(AUTOSHOW_PREFIX + dialogName, true));
    }

    /**
     * Sets whether the dialog of the given name should be shown automatically. The name is an
     * arbitrary string chosen by the caller to represent the dialog.
     */
    public static function setAutoshow (dialogName :String, show :Boolean) :void
    {
        getConfig().setValue(AUTOSHOW_PREFIX + dialogName, show);
    }

    /**
     * Gets all the cookie content for the given name. Each element returned is a 2 element array,
     * the first is the name and the second is the value. Single-valued cookies will return a
     * single element array if the cookie is set, or an empty array if not. Prefix cookies will
     * return an element for each cookie that matches the prefix. Set cookies will return a single
     * element with a comma-separated list of the set contents. The list may be an empty string if
     * the set is empty.
     */
    public static function getByName (name :String) :Array
    {
        var values :Array = [];

        function pushSetElements (elems :StringSet) :void {
            values.push([name, elems.asArray().join(", ")]);
        }

        switch (name) {
        case AUTOSHOW_PREFIX:
        case TUTORIAL_PROGRESS_PREFIX:
            for each (var key :String in getConfig().getPropertyNames()) {
                if (StringUtil.startsWith(key, name)) {
                    values.push([key, getConfig().getValue(key, null)]);
                }
            }
            break;
        case IGNORED_TUTORIAL_IDS:
            pushSetElements(getIgnoredTutorialIds());
            break;
        default:
            var value :Object = getConfig().getValue(name, null);
            if (value != null) {
                values.push([name, value]);
            }
            break;
        }
        return values;
    }

    /**
     * Removes all cookies with names in the given array.
     */
    public static function removeAll (names :Array) :int
    {
        var count :int = 0;
        for each (var name :String in names) {
            switch (name) {
            case IGNORED_TUTORIAL_IDS:
                count += getIgnoredTutorialIds().size();
                getIgnoredTutorialIds().clear();
                break;
            case AUTOSHOW_PREFIX:
            case TUTORIAL_PROGRESS_PREFIX:
                for each (var key :String in getConfig().getPropertyNames()) {
                    if (StringUtil.startsWith(key, name)) {
                        getConfig().remove(key);
                        ++count;
                    }
                }
                break;
            default:
                getConfig().remove(name);
                ++count;
                break;
            }

            // TODO: event dispatch? complicated because all default values are encoded in the
            // individual access methods
        }

        return count;
    }

    protected static function useSoundVolume () :void
    {
        // set up the global sound transform
        SoundMixer.soundTransform = new SoundTransform(getSoundVolume());
    }

    protected static function getIgnoredTutorialIds () :StringSet
    {
        if (_ignoredTutorialIds == null) {
            _ignoredTutorialIds = new StringSet(getConfig(), IGNORED_TUTORIAL_IDS);
        }
        return _ignoredTutorialIds;
    }

    protected static function getConfig () :Config
    {
        Preconditions.checkNotNull(_config, "Prefs.init must be called before Prefs is used");
        return _config;
    }

    /** A set of tutorial item ids that have been ignored. */
    protected static var _ignoredTutorialIds :StringSet;

    /** Our config object. Access should go through getConfig. */
    protected static var _config :Config;
    private static const log :Log = Log.getLog(Prefs);
}
}

import com.threerings.util.Config;
import com.threerings.util.NamedValueEvent;
import com.threerings.util.Util;

import com.threerings.orth.client.Prefs;

/**
 * Represents a configuration value that is a set of strings.
 */
class StringSet
{
    /**
     * Creates a new string set using the given config with the given name.
     */
    public function StringSet (config :Config, name :String)
    {
        _config = config;
        _name = name;
        _contents = _config.getValue(_name, null) as Object;
        if (_contents == null) {
            _contents = new Object();
        }
    }

    /**
     * Returns the number of elements in the set.
     */
    public function size () :int
    {
        var count :int = 0;
        for each (var key :String in _contents) {
            ++count;
        }
        return count;
    }

    /**
     * Return all members of the set as an array of strings.
     */
    public function asArray () :Array
    {
        return Util.keys(_contents);
    }

    /**
     * Updates a value's presence in the set.
     */
    public function update (value :String, present :Boolean) :void
    {
        if (contains(value) == present) {
            return;
        }

        if (present) {
            _contents[value] = true;

        } else {
            delete _contents[value];
        }

        _config.setValue(_name, _contents, false); // don't flush
        Prefs.events.dispatchEvent(new NamedValueEvent(_name, value, present));
    }

    /**
     * Removes all elements from the set.
     */
    public function clear () :void
    {
        _config.setValue(_name, null);
        _contents = new Object();
    }

    /**
     * Tests if the set contains the given value.
     */
    public function contains (value :String) :Boolean
    {
        return value in _contents;
    }

    protected var _name :String;
    protected var _config :Config;
    protected var _contents :Object;
}
