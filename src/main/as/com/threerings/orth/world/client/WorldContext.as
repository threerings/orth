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
public class WorldContext
    implements CrowdContext
{
    public function WorldContext ()
    {
        _injector.mapValue(WorldClient, _injector.getInstance(WorldClient));
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

    [Inject] protected var _injector :Injector;
    [Inject] protected var _client :WorldClient;
    [Inject] protected var _topPanel :TopPanel;

    [Inject] protected var _msgMgr :MessageManager;
    [Inject] protected var _locDir :LocationDirector;
    [Inject] protected var _occDir :OccupantDirector;
    [Inject] protected var _chatDir :ChatDirector;
}
}
