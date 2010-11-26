//
// $Id: StudioClient.as 12846 2008-10-26 02:37:57Z ray $

package com.threerings.orth.room.client {
import com.threerings.orth.world.client.WorldContext;
import com.threerings.orth.world.client.WorldClient;

import flash.display.Stage;

public class StudioClient extends WorldClient
{
    public function StudioClient (stage :Stage, params :Object)
    {
        super(stage);

        _roomStudioController = new RoomStudioController();
        _roomStudioController.init(_wctx, new RoomConfig());
        _wctx.setPlaceView(_roomStudioController.getPlaceView());
    }

    public function getPlaceView () :RoomStudioView
    {
        return _roomStudioController.getPlaceView() as RoomStudioView;
    }

    override public function getHostname () :String
    {
        // we do this to trick WorldClient into calling logon().
        return "studio";
    }

    override public function logon () :Boolean
    {
        // we do nothing here
        return false;
    }

    // from WorldClient
    override protected function createContext () :WorldContext
    {
        return (_wctx = new StudioContext(this));
    }

    protected var _roomStudioController :RoomStudioController;
}
}
