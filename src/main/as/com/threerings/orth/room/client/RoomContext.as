//
// $Id: $

package com.threerings.orth.room.client {

import com.threerings.crowd.chat.client.ChatDirector;
import com.threerings.crowd.client.LocationDirector;
import com.threerings.crowd.client.OccupantDirector;
import com.threerings.crowd.client.PlaceView;

import com.threerings.whirled.client.SceneDirector;
import com.threerings.whirled.util.WhirledContext;

import com.threerings.orth.chat.client.OrthChatDirector;

import com.threerings.orth.client.TopPanel;

import com.threerings.orth.room.client.MediaDirector;
import com.threerings.orth.room.client.OrthSceneDirector;

import com.threerings.orth.world.client.WorldContext;
import com.threerings.orth.world.client.WorldController;

/**
 * Defines services for the Room client.
 */
public class RoomContext
    implements WhirledContext, WorldContext
{
    // from WhirledContext
    public function getSceneDirector () :SceneDirector
    {
        return _sceneDir;
    }

    // from CrowdContext
    function getLocationDirector () :LocationDirector
    {
        return _locDir;
    }

    // from CrowdContext
    function getOccupantDirector () :OccupantDirector
    {
        return _occDir;
    }

    // from CrowdContext
    function getChatDirector () :ChatDirector
    {
        return _chatDir;
    }

    // from CrowdContext
    function setPlaceView (view :PlaceView) :void
    {
        _topPanel.setMainView(view);
    }

    // from CrowdContext
    function clearPlaceView (view :PlaceView) :void
    {
        _topPanel.clearMainView(view);
    }

    protected const _sceneDir :OrthSceneDirector = inject(OrthSceneDirector);
    protected const _locDir :LocationDirector = inject(LocationDirector);
    protected const _occDir :OccupantDirector = inject(OccupantDirector);
    protected const _chatDir :OrthChatDirector = inject(OrthChatDirector);
    protected const _topPanel :TopPanel = inject(TopPanel);
}
}
