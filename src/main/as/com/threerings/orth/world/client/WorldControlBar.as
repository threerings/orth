//
// $Id: WorldControlBar.as 18485 2009-10-24 01:12:12Z jamie $

package com.threerings.orth.world.client {
import com.threerings.orth.room.client.RoomView;
import com.threerings.orth.ui.FloatingPanel;

import flash.events.MouseEvent;

import flash.geom.Point;

import com.threerings.flex.CommandButton;
import com.threerings.flex.FlexUtil;
import com.threerings.orth.client.ControlBar;
import com.threerings.orth.world.client.WorldContext;

/**
 * Configures the control bar with World-specific stuff.
 */
public class WorldControlBar extends ControlBar
{
    /** A button for room-related crap. */
    public var roomBtn :CommandButton;

    /** Hovering over this shows clickable components. */
    public var hotZoneBtn :CommandButton;

    /** A button for popping up the friends list. */
    public var friendsBtn :CommandButton;

    /** Handles the two party-related popups. */
    public var partyBtn :CommandButton;

    public var foolsBtn :CommandButton;

    /**
     * Constructor.
     */
    public function WorldControlBar (ctx :WorldContext)
    {
        super(ctx);
        _wctx = ctx;
    }

    // from ControlBar
    override protected function createControls () :void
    {
        super.createControls();

        roomBtn = createButton("controlBarButtonRoom", "i.room");
        roomBtn.toggle = true;
        roomBtn.setCommand(WorldController.POP_ROOM_MENU, roomBtn);

        hotZoneBtn = createButton("controlBarHoverZone", "i.hover");
        hotZoneBtn.toggle = true;
        hotZoneBtn.setCallback(updateHot);
        hotZoneBtn.addEventListener(MouseEvent.ROLL_OVER, hotHandler);
        hotZoneBtn.addEventListener(MouseEvent.ROLL_OUT, hotHandler);

        friendsBtn = createButton("controlBarFriendButton", "i.friends");
        friendsBtn.toggle = true;
        friendsBtn.setCallback(FloatingPanel.createPopper(function () :FloatingPanel {
            return new FriendsListPanel(_wctx);
        }, friendsBtn));

        partyBtn = createButton("controlBarPartyButton", "i.party");
        partyBtn.toggle = true;
        partyBtn.setCallback(FloatingPanel.createPopper(function () :FloatingPanel {
            return _wctx.getPartyDirector().createAppropriatePartyPanel();
        }, partyBtn));
    }

    override protected function checkControls (... ignored) :void
    {
        const isLoggedOn :Boolean = _ctx.getClient().isLoggedOn();
        friendsBtn.enabled = isLoggedOn;
        partyBtn.enabled = isLoggedOn;

        super.checkControls();
    }

    // from ControlBar
    override protected function addControls () :void
    {
        super.addControls();
        var state :UIState = _ctx.getUIState();

        function isInRoom () :Boolean {
            return state.inRoom;
        }

        function showFriends () :Boolean {
            return true;
        }

        function showParty () :Boolean {
            return true;
        }

        addButton(friendsBtn, showFriends, GLOBAL_PRIORITY);
        addButton(partyBtn, showParty, GLOBAL_PRIORITY + 1);
        addButton(roomBtn, isInRoom, PLACE_PRIORITY);
        addButton(hotZoneBtn, isInRoom, PLACE_PRIORITY);
    }

    protected function updateHot (on :Boolean) :void
    {
        if (on != _hotOn) {
            _hotOn = on;
            var roomView :RoomView = _ctx.getPlaceView() as RoomView;
            if (roomView != null) {
                roomView.hoverAllFurni(on);
            }
        }
    }

    protected function hotHandler (event :MouseEvent) :void
    {
        if (!hotZoneBtn.selected) {
            updateHot(event.type == MouseEvent.ROLL_OVER);
        }
    }

    /** Our context, cast as a WorldContext. */
    protected var _wctx :WorldContext;

    protected var _hotOn :Boolean;
}
}
