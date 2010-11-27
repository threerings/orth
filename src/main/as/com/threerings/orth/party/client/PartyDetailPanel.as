//
// $Id$

package com.threerings.orth.party.client {

import mx.containers.HBox;
import mx.containers.VBox;

import mx.controls.Label;

import com.threerings.flex.CommandButton;
import com.threerings.flex.FlexUtil;

import com.threerings.orth.client.Msgs;
import com.threerings.orth.ui.FloatingPanel;
import com.threerings.orth.ui.MediaWrapper;
import com.threerings.orth.ui.PlayerList;

import com.threerings.orth.world.client.WorldContext;
import com.threerings.orth.world.client.WorldController;

import com.threerings.orth.party.data.PartyDetail;
import com.threerings.orth.party.data.PartyPeep;

public class PartyDetailPanel extends FloatingPanel
{
    public function PartyDetailPanel (ctx :WorldContext, detail :PartyDetail)
    {
        super(ctx, detail.summary.name);
        showCloseButton = true;
        _detail = detail;
    }

    override protected function createChildren () :void
    {
        super.createChildren();

        var topBox :HBox = new HBox();
        topBox.addChild(MediaWrapper.createView(Group.logo(_detail.summary.icon)));

        var infoBox :VBox = new VBox();
        infoBox.addChild(FlexUtil.createLabel(_detail.summary.group.toString()));
        var status :Label = FlexUtil.createLabel(null, "partyStatus");
        PartyDirector.formatStatus(status, _detail.info.status, _detail.info.statusType);
        infoBox.addChild(status);
        infoBox.addChild(FlexUtil.createLabel(
            Msgs.PARTY.get("l.recruit_" + _detail.info.recruitment) + "  " +
                _detail.info.population));
        if (WorldContext(_ctx).getPartyDirector().getPartyId() != _detail.info.id) {
            infoBox.addChild(new CommandButton(Msgs.PARTY.get("b.join"),
                WorldController.JOIN_PARTY, _detail.info.id));
        }
        topBox.addChild(infoBox);
        addChild(topBox);

        var roster :PlayerList = new PlayerList(
            PeepRenderer.createFactory(WorldContext(_ctx), _detail.info),
            PartyPeep.createSortByOrder(_detail.info));
        addChild(roster);
        roster.setData(_detail.peeps);
    }

    protected var _detail :PartyDetail;
}
}
