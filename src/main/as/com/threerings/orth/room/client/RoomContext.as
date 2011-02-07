//
// $Id: $

package com.threerings.orth.room.client {
import flash.display.DisplayObject;

import flashx.funk.ioc.inject;

import com.threerings.crowd.chat.client.ChatDirector;
import com.threerings.crowd.client.LocationDirector;
import com.threerings.crowd.client.OccupantDirector;
import com.threerings.crowd.client.PlaceView;
import com.threerings.whirled.client.SceneDirector;
import com.threerings.whirled.util.WhirledContext;

import com.threerings.presents.client.Client;
import com.threerings.presents.dobj.DObjectManager;

import com.threerings.orth.client.TopPanel;
import com.threerings.orth.data.OrthName;
import com.threerings.orth.room.client.OrthSceneDirector;
import com.threerings.orth.room.data.RoomPlace;
import com.threerings.orth.room.data.SocializerObject;
import com.threerings.orth.world.client.WorldClient;
import com.threerings.orth.world.client.WorldContext;
import com.threerings.orth.world.data.OrthPlace;
import com.threerings.orth.world.data.OrthPlayerBody;

/**
 * Defines services for the Room client.
 */
public class RoomContext
    implements WhirledContext, WorldContext
{
    public function RoomContext ()
    {
        // i expect this will be RoomClient() before too long
        _client = new WorldClient();

        // configure and launch client, however exactly we decide to make the WorldContext
        // implementations aware of e.g. username / token
    }

    // from PresentsContext
    public function getClient () :Client
    {
        return _client;
    }

    // from PresentsContext
    public function getDObjectManager () :DObjectManager
    {
        return _client.getDObjectManager();
    }

    // from CrowdContext
    public function getLocationDirector () :LocationDirector
    {
        return _locDir;
    }

    // from CrowdContext
    public function getOccupantDirector () :OccupantDirector
    {
        return _occDir;
    }

    // from CrowdContext
    public function getChatDirector () :ChatDirector
    {
        return null;

        // ORTH TODO
        // return _chatDir;
    }

    // from CrowdContext
    public function setPlaceView (view :PlaceView) :void
    {
        _topPanel.setMainView(DisplayObject(view));
    }

    // from CrowdContext
    public function clearPlaceView (view :PlaceView) :void
    {
        _topPanel.clearMainView(DisplayObject(view));
    }

    // from WhirledContext
    public function getSceneDirector () :SceneDirector
    {
        return _sceneDir;
    }

    // from WorldContext
    public function getPlayerBody () :OrthPlayerBody
    {
        return _client.getClientObject() as SocializerObject;
    }

    // from WorldContext
    public function getMyName () :OrthName
    {
        var body :OrthPlayerBody = getPlayerBody();

        return (body != null) ? SocializerObject(body).name : null;
    }

    // from WorldContext
    public function getWorldClient () :WorldClient
    {
        return _client;
    }

    // from WorldContext
    public function gotoPlace (place :OrthPlace) :void
    {
        _sceneDir.moveTo(RoomPlace(place).sceneId);
    }

    /** Return a fully casted socializer object, or null if we're not logged on. */
    public function getSocializerObject () :SocializerObject
    {
        return _client.getClientObject() as SocializerObject;
    }

    protected var _client :WorldClient;

    protected const _locDir :LocationDirector = inject(LocationDirector);
    protected const _occDir :OccupantDirector = inject(OccupantDirector);
    protected const _sceneDir :OrthSceneDirector = inject(OrthSceneDirector);
    protected const _topPanel :TopPanel = inject(TopPanel);

    // ORTH TODO: This is highly dubious and will change dramatically, as most chatting will be sent
    // TODO: over the Aether wire and our chat system needs to be multi-connection at any rate.
    // protected const _chatDir :OrthChatDirector = inject(OrthChatDirector);
}
}
