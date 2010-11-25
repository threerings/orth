//
// $Id: WorldContext.as 18724 2009-11-19 19:21:47Z jamie $

package com.threerings.msoy.world.client {

import com.threerings.whirled.client.SceneDirector;
import com.threerings.whirled.spot.client.SpotSceneDirector;
import com.threerings.whirled.util.WhirledContext;

import com.threerings.msoy.chat.client.MsoyChatDirector;
import com.threerings.msoy.game.client.GameDirector;
import com.threerings.msoy.room.client.MediaDirector;
import com.threerings.msoy.room.client.MsoySceneDirector;
import com.threerings.msoy.room.client.WorldProperties;

import com.threerings.msoy.client.ControlBar;
import com.threerings.msoy.client.MsoyContext;
import com.threerings.msoy.client.MsoyController;
import com.threerings.msoy.client.persist.RuntimeSceneRepository;
import com.threerings.msoy.data.MemberObject;
import com.threerings.msoy.data.MsoyTokenRing;

import com.threerings.msoy.world.tour.client.TourDirector;

import com.threerings.msoy.party.client.PartyDirector;

import com.threerings.msoy.tutorial.client.TutorialDirector;

/**
 * Defines services for the World client.
 */
public class WorldContext extends MsoyContext
    implements WhirledContext
{
    /** Contains non-persistent properties that are set in various places and can be bound to to be
     * notified when they change. */
    public var worldProps :WorldProperties = new WorldProperties();

    public function WorldContext (client :WorldClient)
    {
        super(client);

        // some directors we create here (unsuppressed)
        _mediaDir = new MediaDirector(this);
        _controller = new WorldController(this, _topPanel);
    }

    // from WhirledContext
    public function getSceneDirector () :SceneDirector
    {
        return _sceneDir;
    }

    /**
     * Convenience method.
     */
    public function getMemberObject () :MemberObject
    {
        return (_client.getClientObject() as MemberObject);
    }

    /**
     * Returns our client casted to a WorldClient.
     */
    public function getWorldClient () :WorldClient
    {
        return (getClient() as WorldClient);
    }

    /**
     * Get the media director.
     */
    public function getMediaDirector () :MediaDirector
    {
        return _mediaDir;
    }

    /**
     * Get the GameDirector.
     */
    public function getGameDirector () :GameDirector
    {
        return _gameDir;
    }

    /**
     * Get the WorldDirector.
     */
    public function getWorldDirector () :WorldDirector
    {
        return _worldDir;
    }

    /**
     * Get the SpotSceneDirector.
     */
    public function getSpotSceneDirector () :SpotSceneDirector
    {
        return _spotDir;
    }

    /**
     * Get the MemberDirector.
     */
    public function getMemberDirector () :MemberDirector
    {
        return _memberDir;
    }

    /**
     * Get the tour director.
     */
    public function getTourDirector () :TourDirector
    {
        return _tourDir;
    }

    /**
     * Get the party director.
     */
    public function getPartyDirector () :PartyDirector
    {
        return _partyDir;
    }

    /**
     * Get the tutorial director.
     */
    public function getTutorialDirector () :TutorialDirector
    {
        return _tutorialDir;
    }

    /**
     * Returns the top-level world controller.
     */
    public function getWorldController () :WorldController
    {
        return _controller;
    }

    /**
     * Returns the world control bar.
     */
    public function getWorldControlBar () :WorldControlBar
    {
        return WorldControlBar(getControlBar());
    }

    // from MsoyContext
    override public function getTokens () :MsoyTokenRing
    {
        // if we're not logged on, claim to have no privileges
        return (getMemberObject() == null) ? new MsoyTokenRing() : getMemberObject().tokens;
    }

    // from MsoyContext
    override public function getMsoyController () :MsoyController
    {
        return _controller;
    }

    // from MsoyContext
    override protected function createControlBar () :ControlBar
    {
        return new WorldControlBar(this);
    }

    override protected function createAdditionalDirectors () :void
    {
        super.createAdditionalDirectors();

        _sceneDir = new MsoySceneDirector(this, _locDir, new RuntimeSceneRepository());
        _spotDir = new SpotSceneDirector(this, _locDir, _sceneDir);
        _gameDir = new GameDirector(this);
        _worldDir = new WorldDirector(this);
        _memberDir = new MemberDirector(this);
        _tourDir = new TourDirector(this);
        _partyDir = new PartyDirector(this);
        _tutorialDir = new TutorialDirector(this);
    }

    protected var _controller :WorldController;

    protected var _sceneDir :SceneDirector;
    protected var _spotDir :SpotSceneDirector;
    protected var _gameDir :GameDirector;
    protected var _mediaDir :MediaDirector;
    protected var _worldDir :WorldDirector;
    protected var _memberDir :MemberDirector;
    protected var _tourDir :TourDirector;
    protected var _partyDir :PartyDirector;
    protected var _tutorialDir :TutorialDirector;
}
}
