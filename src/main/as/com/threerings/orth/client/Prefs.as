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
 * Dispatched when a piece of media is bleeped or unbleeped.
 * This is dispatched on the 'events' object.
 *
 * @eventType com.threerings.orth.client.Prefs.BLEEPED_MEDIA;
 * name: mediaId (may be the GLOBAL_BLEEP constant)
 * value: bleeped (Boolean)
 */
[Event(name="bleepedMedia", type="com.threerings.util.NamedValueEvent")]

/**
 * Dispatched when a tutorial id is ignored.
 * This is dispatched on the 'events' object.
 *
 * @eventType com.threerings.orth.client.Prefs.IGNORED_TUTORIAL_IDS;
 * name: tutorialItemId
 * value: ignored (Boolean)
 */
[Event(name="ignoredTutIds", type="com.threerings.util.NamedValueEvent")]

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
    public static const CHAT_FONT_SIZE :String = "chatFontSize";
    public static const CHAT_DECAY :String = "chatDecay";
    public static const CHAT_FILTER :String = "chatFilter";
    public static const CHAT_HISTORY :String = "chatHistory";
    public static const CHAT_SIDEBAR :String = "chatSliding"; // legacy name
    public static const OCCUPANT_LIST :String = "occupantList";
    public static const LOG_TO_CHAT :String = "logToChat";
    public static const BLEEPED_MEDIA :String = "bleepedMedia";
    public static const PARTY_GROUP :String = "partyGroup";
    public static const PERMAGUEST_USERNAME :String = "permaguestUsername";
    public static const USE_CUSTOM_BACKGROUND_COLOR :String = "useCustomBgColor";
    public static const CUSTOM_BACKGROUND_COLOR :String = "customBgColor";
    public static const AUTOSHOW_PREFIX :String = "autoShow_";
    public static const ROOM_ZOOM :String = "roomZoom";
    public static const IGNORED_TUTORIAL_IDS :String = "ignoredTutIds";
    public static const TUTORIAL_PROGRESS_PREFIX :String = "tutProgress_";

    public static const APRIL_FOOLS :String = "aprilFools";

    /** List of cookies (that the user may see and clear). */
    public static const ALL_KEYS :Array = [
        VOLUME, CHAT_FONT_SIZE, CHAT_DECAY, CHAT_FILTER, CHAT_HISTORY, CHAT_SIDEBAR, OCCUPANT_LIST,
        LOG_TO_CHAT, BLEEPED_MEDIA, PARTY_GROUP, USE_CUSTOM_BACKGROUND_COLOR,
        CUSTOM_BACKGROUND_COLOR, ROOM_ZOOM, IGNORED_TUTORIAL_IDS, TUTORIAL_PROGRESS_PREFIX,
        AUTOSHOW_PREFIX];

    public static const CHAT_FONT_SIZE_MIN :int = 10;
    public static const CHAT_FONT_SIZE_MAX :int = 24;

    public static const GLOBAL_BLEEP :String = "_bleep_";

    public static const IS_APRIL_FOOLS :Boolean =
        ((new Date().month) == 3) && ((new Date().date) == 1); // April 1st

    public static function setEmbedded (embedded :Boolean) :void
    {
        _config.setPath(embedded ? null : CONFIG_PATH);
        useSoundVolume();
    }

    /**
     * Set the build time. Return true if it's changed. Should only be done on non-embedded clients.
     */
    public static function setBuildTime (buildTime :String) :Boolean
    {
        var lastBuild :String = (_config.getValue("lastBuild", null) as String);
        if (lastBuild != buildTime) {
            _config.setValue("lastBuild", buildTime);

            // TEMP code: please to remove someday TODO
            var oldVal :Object = _config.getValue("gridAutoshow", null);
            if (oldVal != null) {
                _config.remove("gridAutoshow");
                setAutoshow("grid", Boolean(oldVal));
            }
            // END: TEMP TODO

            // TEMP code: please to remove someday TODO
            if (_config.getValue("zoom", null) != null) {
                _config.remove("zoom");
            }
            // END: TEMP TODO
            return true;
        }
        return false;
    }

    public static function isAprilFoolsEnabled () :Boolean
    {
        return IS_APRIL_FOOLS && _config.getValue(APRIL_FOOLS, true);
    }

    public static function setAprilFoolsEnabled (enabled :Boolean) :void
    {
        _config.setValue(APRIL_FOOLS, enabled);
    }

    /**
     * Effect the global sound volume.
     */
    public static function useSoundVolume () :void
    {
        // set up the global sound transform
        SoundMixer.soundTransform = new SoundTransform(getSoundVolume());
    }

    public static function getUsername () :String
    {
        return (_config.getValue(USERNAME, "") as String);
    }

    public static function setUsername (username :String) :void
    {
        _config.setValue(USERNAME, username);
    }

    public static function getPermaguestUsername () :String
    {
        return (_machineConfig.getValue(PERMAGUEST_USERNAME, null) as String);
    }

    public static function setPermaguestUsername (username :String) :void
    {
        if (username == null) {
            _machineConfig.remove(PERMAGUEST_USERNAME);

        } else {
            _machineConfig.setValue(PERMAGUEST_USERNAME, username);
        }
    }

    public static function getMachineIdent () :String
    {
        return (_config.getValue(MACHINE_IDENT, "") as String);
    }

    public static function setMachineIdent (ident :String) :void
    {
        _config.setValue(MACHINE_IDENT, ident);
    }

    public static function setMediaBleeped (id :String, bleeped :Boolean) :void
    {
        getBleepedMedia().update(id, bleeped);
    }

    /**
     * Return true if the specified media is bleeped, regardless of the global bleep setting.
     */
    public static function isMediaBleeped (id :String) :Boolean
    {
        return getBleepedMedia().contains(id);
    }

    public static function setGlobalBleep (bleeped :Boolean) :void
    {
        _globalBleep = bleeped;
        events.dispatchEvent(new NamedValueEvent(BLEEPED_MEDIA, GLOBAL_BLEEP, bleeped));
    }

    public static function isGlobalBleep () :Boolean
    {
        return _globalBleep;
    }

    public static function getSoundVolume () :Number
    {
        return (_config.getValue(VOLUME, 1) as Number);
    }

    public static function setSoundVolume (vol :Number) :void
    {
        _config.setValue(VOLUME, vol);
        useSoundVolume();
    }

    /**
     * Returns the last set value for the room zoom or null if not set.
     */
    public static function getRoomZoom () :String
    {
        return _config.getValue(ROOM_ZOOM, null) as String;
    }

    /**
     * Sets the room zoom default.
     */
    public static function setRoomZoom (value :String) :void
    {
        _config.setValue(ROOM_ZOOM, value);
    }

    /**
     * Get the preferred chat font size.
     * Default value: 14.
     */
    public static function getChatFontSize () :int
    {
        return (_config.getValue(CHAT_FONT_SIZE, 14) as int);
    }

    /**
     * Set the user's new preferred chat size.
     */
    public static function setChatFontSize (newSize :int) :void
    {
        _config.setValue(CHAT_FONT_SIZE, newSize);
    }

    /**
     * Get the value of the chat decay setting, which specifies how long
     * chat should remain before fading out.
     *
     * @return an integer: 0 = fast, 1 = medium (default), 2 = slow.
     */
    public static function getChatDecay () :int
    {
        // in embedded mode (when configs don't persist, we default to fast chat clearing)
        return (_config.getValue(CHAT_DECAY, _config.isPersisting() ? 1 : 0) as int);
    }

    /**
     * Set the new chat decay value.
     */
    public static function setChatDecay (value :int) :void
    {
        _config.setValue(CHAT_DECAY, value);
    }

    /**
     * Return the chat filtration level, as a constant from
     * com.threerings.crowd.chat.client.CurseFilter.
     */
    public static function getChatFilterLevel () :int
    {
        // 2 == CurseFilter.VERNACULAR, which is a bitch to import and
        // the subclass doesn't have it.
        return (_config.getValue(CHAT_FILTER, 2) as int);
    }

    /**
     * Set the chat filtration level.
     */
    public static function setChatFilterLevel (lvl :int) :void
    {
        _config.setValue(CHAT_FILTER, lvl);
    }

    /**
     * Returns whether chat history is on or off.
     */
    public static function getShowingChatHistory () :Boolean
    {
        return (_config.getValue(CHAT_HISTORY, false) as Boolean);
    }

    public static function setShowingChatHistory (showing :Boolean) :void
    {
        _config.setValue(CHAT_HISTORY, showing);
    }

    /**
     * Returns whether chat is in sidebar mode.
     */
    public static function getSidebarChat () :Boolean
    {
        return (_config.getValue(CHAT_SIDEBAR, false) as Boolean);
    }

    public static function setSidebarChat (sidebar :Boolean) :void
    {
        _config.setValue(CHAT_SIDEBAR, sidebar);
    }

    /**
     * Returns whether to display the channel occupant list or not.
     */
    public static function getShowingOccupantList () :Boolean
    {
        return (_config.getValue(OCCUPANT_LIST, false) as Boolean);
    }

    public static function setShowingOccupantList (showing :Boolean) :void
    {
        _config.setValue(OCCUPANT_LIST, showing);
    }

    public static function getPartyGroup () :int
    {
        return (_config.getValue(PARTY_GROUP, 0) as int);
    }

    public static function setPartyGroup (groupId :int) :void
    {
        _config.setValue(PARTY_GROUP, groupId);
    }

    public static function getUseCustomBackgroundColor () :Boolean
    {
        return (_config.getValue(USE_CUSTOM_BACKGROUND_COLOR, true) as Boolean);
    }

    public static function setUseCustomBackgroundColor (value :Boolean) :void
    {
        _config.setValue(USE_CUSTOM_BACKGROUND_COLOR, value);
    }

    public static function getCustomBackgroundColor () :uint
    {
        return (_config.getValue(CUSTOM_BACKGROUND_COLOR, 0xffffff) as uint);
    }

    public static function setCustomBackgroundColor (value :uint) :void
    {
        _config.setValue(CUSTOM_BACKGROUND_COLOR, value);
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
        return _config.getValue(TUTORIAL_PROGRESS_PREFIX + id, 0) as int;
    }

    public static function setTutorialProgress (id :String, progress :int) :void
    {
        _config.setValue(TUTORIAL_PROGRESS_PREFIX + id, progress);
    }

    /**
     * Returns whether the dialog of the given name should be shown automatically. The name is an
     * arbitrary string chosen by the caller to represent the dialog.
     */
    public static function getAutoshow (dialogName :String) :Boolean
    {
        return Boolean(_config.getValue(AUTOSHOW_PREFIX + dialogName, true));
    }

    /**
     * Sets whether the dialog of the given name should be shown automatically. The name is an
     * arbitrary string chosen by the caller to represent the dialog.
     */
    public static function setAutoshow (dialogName :String, show :Boolean) :void
    {
        _config.setValue(AUTOSHOW_PREFIX + dialogName, show);
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
            for each (var key :String in _config.getPropertyNames()) {
                if (StringUtil.startsWith(key, name)) {
                    values.push([key, _config.getValue(key, null)]);
                }
            }
            break;
        case BLEEPED_MEDIA:
            pushSetElements(getBleepedMedia());
            break;
        case IGNORED_TUTORIAL_IDS:
            pushSetElements(getIgnoredTutorialIds());
            break;
        default:
            var value :Object = _config.getValue(name, null);
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
            case BLEEPED_MEDIA:
                count += getBleepedMedia().size();
                getBleepedMedia().clear();
                break;
            case IGNORED_TUTORIAL_IDS:
                count += getIgnoredTutorialIds().size();
                getIgnoredTutorialIds().clear();
                break;
            case AUTOSHOW_PREFIX:
            case TUTORIAL_PROGRESS_PREFIX:
                for each (var key :String in _config.getPropertyNames()) {
                    if (StringUtil.startsWith(key, name)) {
                        _config.remove(key);
                        ++count;
                    }
                }
                break;
            default:
                _config.remove(name);
                ++count;
                break;
            }

            // TODO: event dispatch? complicated because all default values are encoded in the
            // individual access methods
        }

        return count;
    }

    protected static function getBleepedMedia () :StringSet
    {
        if (_bleepedMedia == null) {
            _bleepedMedia = new StringSet(_config, BLEEPED_MEDIA);
        }
        return _bleepedMedia;
    }

    protected static function getIgnoredTutorialIds () :StringSet
    {
        if (_ignoredTutorialIds == null) {
            _ignoredTutorialIds = new StringSet(_config, IGNORED_TUTORIAL_IDS);
        }
        return _ignoredTutorialIds;
    }

    /** The path of our config object. */
    protected static const CONFIG_PATH :String = "rsrc/config/msoy";

    /** A set of media ids that are bleeped. */
    protected static var _bleepedMedia :StringSet;
    protected static var _globalBleep :Boolean;

    /** A set of tutorial item ids that have been ignored. */
    protected static var _ignoredTutorialIds :StringSet;

    /** Our config object. */
    protected static var _config :Config = new Config(null);

    protected static var _machineConfig :Config = new Config(CONFIG_PATH);

    /**
    * A static initializer.
    */
    private static function staticInit () :void
    {
        // route events
        _config.addEventListener(Config.CONFIG_VALUE_SET, events.dispatchEvent);
        _machineConfig.addEventListener(Config.CONFIG_VALUE_SET, events.dispatchEvent);
    }

    staticInit();
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
