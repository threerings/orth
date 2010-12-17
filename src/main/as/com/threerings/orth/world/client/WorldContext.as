//
// $Id: $
package com.threerings.orth.world.client
{
import com.threerings.crowd.chat.client.ChatDirector;
import com.threerings.crowd.client.LocationDirector;
import com.threerings.crowd.client.OccupantDirector;
import com.threerings.crowd.client.PlaceView;
import com.threerings.crowd.util.CrowdContext;
import com.threerings.orth.client.OrthContext;
import com.threerings.orth.data.OrthCodes;
import com.threerings.presents.client.Client;
import com.threerings.presents.dobj.DObjectManager;
import com.threerings.util.Name;

public class WorldContext
    implements CrowdContext
{
    public function WorldContext (ctx :OrthContext, hostname :String, ports :Array,
        username :Name, sessionToken :String)
    {
        _octx = ctx;

        _client = new WorldClient(this, hostname, ports, username, sessionToken);

        _locDir = new LocationDirector(this);
        _occDir = new OccupantDirector(this);

        // NOT ACTUALLY USED
        _chatDir = new ChatDirector(this, ctx.getMessageManager(), OrthCodes.CHAT_MSGS);
    }

    /**
     * Return a reference to the {@link OrthContext}. This value is never null.
     */
    public function get octx () :OrthContext
    {
        return _octx;
    }

    /**
     * Return a reference to our {@link com.threerings.orth.world.client.WorldClient}.
     */
    public function get client () :WorldClient
    {
        return _client;
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
        _octx.topPanel.setPlaceView(view);
    }

    // from CrowdContext
    public function clearPlaceView (view :PlaceView):void
    {
        _octx.topPanel.clearPlaceView(view);
    }

    protected var _client :WorldClient;
    protected var _octx :OrthContext;

    protected var _locDir :LocationDirector;
    protected var _occDir :OccupantDirector;
    protected var _chatDir :ChatDirector;
}
}