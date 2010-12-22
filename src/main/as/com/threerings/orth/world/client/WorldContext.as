//
// $Id: $

package com.threerings.orth.world.client
{
import flash.display.DisplayObject;

import org.swiftsuspenders.Injector;

import com.threerings.util.MessageManager;
import com.threerings.util.Name;

import com.threerings.presents.client.Client;
import com.threerings.presents.dobj.DObjectManager;

import com.threerings.crowd.chat.client.ChatDirector;
import com.threerings.crowd.client.LocationDirector;
import com.threerings.crowd.client.OccupantDirector;
import com.threerings.crowd.client.PlaceView;
import com.threerings.crowd.util.CrowdContext;

import com.threerings.orth.client.OrthContext;
import com.threerings.orth.client.TopPanel;
import com.threerings.orth.data.OrthCodes;


/**
 * ORTH TODO: This must be an interface, not a subclass. This is true for much of the
 * world subpackage, as e.g. rooms derive from threerings.whirled whereas interventions
 * derive directly from threerings.crowd.
 */
[Inject]
public class WorldContext
    implements CrowdContext
{
    public function WorldContext (msgMgr :MessageManager)
    {
        // crowd stuff
        _injector.mapValue(LocationDirector, new LocationDirector(this));
        _injector.mapValue(OccupantDirector, new OccupantDirector(this));
        _injector.mapValue(ChatDirector, new ChatDirector(this, msgMgr, OrthCodes.CHAT_MSGS));
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

    /**
     * THIS CHAT DIRECTOR IS NOT HOOKED UP. DO NOT USE.
     */
    public function getChatDirector () :ChatDirector
    {
        return _chatDir;
    }

    // from CrowdContext
    public function setPlaceView (view :PlaceView):void
    {
        // TODO: OrthPlaceView.selfAsDisplayObject()?
        _topPanel.setMainView(DisplayObject(view));
    }

    // from CrowdContext
    public function clearPlaceView (view :PlaceView):void
    {
        // TODO: OrthPlaceView.selfAsDisplayObject()?
        _topPanel.clearPlaceView(DisplayObject(view));
    }

    [Inject] public var _injector :Injector;
    [Inject] public var _client :WorldClient;
    [Inject] public var _topPanel :TopPanel;

    [Inject] public var _locDir :LocationDirector;
    [Inject] public var _occDir :OccupantDirector;
    [Inject] public var _chatDir :ChatDirector;
}
}
