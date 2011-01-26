//
// $Id$

package com.threerings.orth.party.client {

import com.threerings.orth.client.Msgs;
import com.threerings.orth.client.OrthContext;
import com.threerings.orth.data.PlayerObject;
import com.threerings.orth.party.client.PartyDirector;
import com.threerings.orth.party.data.PartyCodes;

import flashx.funk.ioc.inject;

import mx.containers.Grid;

import mx.controls.CheckBox;
import mx.controls.TextInput;

import com.threerings.util.StringUtil;

import com.threerings.flex.GridUtil;

import com.threerings.orth.ui.FloatingPanel;

/**
 * A dialog used to configure a new party for creation.
 */
public class CreatePartyPanel extends FloatingPanel
{
    public function CreatePartyPanel ()
    {
        super(Msgs.PARTY.get("t.create"));
        setButtonWidth(0);
    }

    /**
     * Can be called after we're open to re-init the values.
     */
    public function init (name :String, inviteAllFriends :Boolean) :void
    {
        _name.text = name;
        _inviteAll.selected = inviteAllFriends;
    }

    override protected function createChildren () :void
    {
        super.createChildren();

        var us :PlayerObject = inject(PlayerObject);

        _name = new TextInput();
        _name.maxChars = PartyCodes.MAX_NAME_LENGTH;
        _name.text = StringUtil.truncate(
            Msgs.PARTY.get("m.default_name", us.playerName.toString()), PartyCodes.MAX_NAME_LENGTH);

        _inviteAll = new CheckBox();
        _inviteAll.selected = true;

        var grid :Grid = new Grid();
        GridUtil.addRow(grid, Msgs.PARTY.get("l.name"), _name);
        GridUtil.addRow(grid, Msgs.PARTY.get("l.invite_friends"), _inviteAll);
        addChild(grid);

        addButtons(CANCEL_BUTTON, OK_BUTTON);
    }

    override protected function okButtonClicked () :void
    {
        _partydir.createParty(_name.text, _inviteAll.selected);
        close();
    }

    [Inject] public var _ctx :OrthContext;
    [Inject] public var _partyDir :PartyDirector;

    protected var _name :TextInput;

    protected var _inviteAll :CheckBox;

    protected const _partydir :PartyDirector = inject(PartyDirector);
}
}
