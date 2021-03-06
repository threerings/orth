//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.room.client {
import flashx.funk.ioc.Module;
import flashx.funk.ioc.inject;

import com.threerings.util.Preconditions;

import com.threerings.presents.client.Client;
import com.threerings.presents.dobj.DObjectManager;

import com.threerings.crowd.chat.client.ChatDirector;
import com.threerings.crowd.client.LocationDirector;
import com.threerings.crowd.client.OccupantDirector;
import com.threerings.crowd.client.PlaceView;

import com.threerings.whirled.client.SceneDirector;
import com.threerings.whirled.spot.client.SpotSceneDirector;
import com.threerings.whirled.util.WhirledContext;

import com.threerings.orth.client.TopPanel;
import com.threerings.orth.data.PlayerName;
import com.threerings.orth.locus.client.LocusClient;
import com.threerings.orth.locus.client.LocusContext;
import com.threerings.orth.locus.data.HostedLocus;
import com.threerings.orth.locus.data.Locus;
import com.threerings.orth.room.data.RoomLocus;
import com.threerings.orth.room.data.SocializerObject;

/**
 * Defines services for the Room client.
 */
public class RoomContext
    implements WhirledContext, LocusContext
{
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

    public function get myName () :PlayerName
    {
        var body :SocializerObject = getSocializerObject();

        return (body != null) ? body.name : null;
    }

    /** Return a fully casted socializer object, or null if we're not logged on. */
    public function getSocializerObject () :SocializerObject
    {
        return _client.getClientObject() as SocializerObject;
    }

    // from LocusContext
    public function get locusClient () :LocusClient
    {
        return _client;
    }

    public function prepareForConnection (
        locus :HostedLocus, success :Function, fail :Function) :Boolean
    {
        return false;
    }

    // from LocusContext
    public function go (locus :Locus) :void
    {
        Preconditions.checkArgument(locus is RoomLocus, "Expecting a RoomLocus");
        var sceneDir :OrthSceneDirector = _module.getInstance(SceneDirector);

        sceneDir.moveToLocalPlace(locus);
    }

    /** We use this for moving around a scene. */
    public function getSpotSceneDirector () :SpotSceneDirector
    {
        return _module.getInstance(SpotSceneDirector);
    }

    protected const _module :Module = inject(Module);
    protected const _client :RoomClient = inject(RoomClient);
    protected const _topPanel :TopPanel = inject(TopPanel);
}
}
