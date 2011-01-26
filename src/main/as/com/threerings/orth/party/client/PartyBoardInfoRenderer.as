//
// $Id: PartyBoardInfoRenderer.as 19431 2010-10-22 22:08:36Z zell $

package com.threerings.orth.party.client {
import com.threerings.orth.data.MediaDescSize;

import flash.events.MouseEvent;

import mx.containers.HBox;
import mx.containers.VBox;
import mx.controls.Label;

import com.threerings.flex.CommandButton;
import com.threerings.flex.FlexUtil;

import com.threerings.orth.client.Msgs;
import com.threerings.orth.data.MediaDesc;
import com.threerings.orth.data.PlayerObject;
import com.threerings.orth.ui.MediaWrapper;

import com.threerings.orth.world.client.WorldContext;
import com.threerings.orth.world.client.WorldController;

import com.threerings.orth.party.data.PartyBoardInfo;

public class PartyBoardInfoRenderer extends HBox
{
    public function PartyBoardInfoRenderer ()
    {
        addEventListener(MouseEvent.CLICK, handleClick);
    }

    override public function set data (value :Object) :void
    {
        super.data = value;
        if (value == null) {
            return;
        }
        var party :PartyBoardInfo = PartyBoardInfo(value);

        _picHolder.removeAllChildren();
        _picHolder.addChild(MediaWrapper.createView(
            party.summary.icon, MediaDescSize.QUARTER_THUMBNAIL_SIZE));

        _name.text = party.summary.name;
        _population.text = String(party.info.population);
        PartyDirector.formatStatus(_status, party.info.status, party.info.statusType);

        var us :PlayerObject = wctx.getPlayerObject();
        _name.setStyle("fontWeight",
            us.isOnlineFriend(party.info.leaderId) ? "bold" : "normal");

        _join.setCommand(WorldController.JOIN_PARTY, party.info.id);
    }

    override protected function createChildren () :void
    {
        super.createChildren();

        // some things are fixed-width
        _population.width = 20;
        // _picHolder and _join will be the same for every row, no size-forcing needed

        // have these two soak up the remaining available width
//        _name.percentWidth = 50;
//        _status.percentWidth = 50;
        // GODDAMN YOU FLEX AND YOUR CHIMPASS LAYOUT
        _name.width = 150;
        _status.width = 160;

        addChild(_picHolder);
        addChild(_name);
        addChild(_population);
        addChild(_status);
        addChild(_join);
    }

    protected function handleClick (event :MouseEvent) :void
    {
        var party :PartyBoardInfo = PartyBoardInfo(data);
        if (party != null) {
            wctx.getPartyDirector().getPartyDetail(party.info.id);
        }
    }

    protected var _picHolder :VBox = new VBox();
    protected var _name :Label = FlexUtil.createLabel(null, "partyName");
    protected var _population :Label = FlexUtil.createLabel(null, "partyPopulation");
    protected var _status :Label = FlexUtil.createLabel(null, "partyStatus");
    protected var _join :CommandButton = new CommandButton(Msgs.PARTY.get("b.join"));
}
}
