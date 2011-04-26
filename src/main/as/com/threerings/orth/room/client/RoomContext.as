//
// $Id: $

package com.threerings.orth.room.client {
import flashx.funk.ioc.inject;

import com.threerings.crowd.chat.client.ChatDirector;
import com.threerings.crowd.client.LocationDirector;
import com.threerings.crowd.client.OccupantDirector;
import com.threerings.crowd.client.PlaceView;
import com.threerings.whirled.client.SceneDirector;
import com.threerings.whirled.spot.client.SpotSceneDirector;
import com.threerings.whirled.util.WhirledContext;

import com.threerings.presents.client.Client;
import com.threerings.presents.dobj.DObjectManager;

import com.threerings.orth.aether.data.PlayerName;
import com.threerings.orth.client.TopPanel;
import com.threerings.orth.locus.client.LocusClient;
import com.threerings.orth.locus.client.LocusContext;
import com.threerings.orth.locus.client.LocusModule;
import com.threerings.orth.locus.data.Locus;
import com.threerings.orth.room.data.SocializerObject;

/**
 * Defines services for the Room client.
 */
public class RoomContext
    implements WhirledContext, LocusContext
{
    public function RoomContext ()
    {
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
        return _module.getInstance(LocationDirector);
    }

    // from CrowdContext
    public function getOccupantDirector () :OccupantDirector
    {
        return _module.getInstance(OccupantDirector);
    }

    // from CrowdContext
    public function getChatDirector () :ChatDirector
    {
        return _module.getInstance(FakeChatDirector);
    }

    // from CrowdContext
    public function setPlaceView (view :PlaceView) :void
    {
        _topPanel.setMainView(RoomWindow(view));
    }

    // from CrowdContext
    public function clearPlaceView (view :PlaceView) :void
    {
        if (_topPanel.getMainView() is RoomWindow) {
            _topPanel.clearMainView();
        }
    }

    // from WhirledContext
    public function getSceneDirector () :SceneDirector
    {
        return _module.getInstance(SceneDirector);
    }

    // from LocusContext
    public function getMyName () :PlayerName
    {
        var body :SocializerObject = getSocializerObject();

        return (body != null) ? body.name : null;
    }

    // from LocusContext
    public function getLocusClient () :LocusClient
    {
        return _client;
    }

    // from LocusContext
    public function go (locus :Locus) :void
    {
        var sceneDir :OrthSceneDirector = _module.getInstance(SceneDirector);
        sceneDir.moveToPlace(locus);
    }

    /** We use this for moving around a scene. */
    public function getSpotSceneDirector () :SpotSceneDirector
    {
        return _module.getInstance(SpotSceneDirector);
    }

    /** Return a fully casted socializer object, or null if we're not logged on. */
    public function getSocializerObject () :SocializerObject
    {
        return _client.getClientObject() as SocializerObject;
    }

    protected const _client :LocusClient = inject(LocusClient);
    protected const _topPanel :TopPanel = inject(TopPanel);
    protected const _module :LocusModule = inject(LocusModule);
}
}
