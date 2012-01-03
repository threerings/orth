//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.ui {

import com.whirled.ui.NameLabel;
import com.whirled.ui.NameLabelCreator;

import com.threerings.util.Log;
import com.threerings.util.Name;

import com.threerings.orth.aether.data.VizPlayerName;

public class OrthNameLabelCreator
    implements NameLabelCreator
{
    public function OrthNameLabelCreator (forRoom :Boolean = false)
    {
        _forRoom = forRoom;
    }

    // from NameLabelCreator
    public function createLabel (name :Name, extrainfo: Object) :NameLabel
    {
        if (!(name is VizPlayerName)) {
            Log.getLog(this).warning("OrthNameLabelCreator only supports VizPlayerName");
            return null;
        }

        return new LabelBox(name as VizPlayerName, _forRoom);
    }

    protected var _forRoom :Boolean;
}
}

import flash.events.MouseEvent;

import flashx.funk.ioc.inject;

import com.whirled.ui.NameLabel;
import com.whirled.ui.PlayerList;

import mx.containers.HBox;
import mx.core.ScrollPolicy;

import com.threerings.crowd.data.OccupantInfo;
import com.threerings.flex.CommandMenu;
import com.threerings.flex.FlexWrapper;

import com.threerings.util.Log;

import com.threerings.orth.aether.data.VizPlayerName;
import com.threerings.orth.client.TopPanel;
import com.threerings.orth.data.MediaDescSize;
import com.threerings.orth.room.client.RoomObjectController;
import com.threerings.orth.ui.MediaWrapper;
import com.threerings.orth.ui.OrthNameLabel;
import com.threerings.orth.world.client.WorldController;

class LabelBox extends HBox
    implements NameLabel
{
    public function LabelBox (name :VizPlayerName, forRoom :Boolean)
    {
        _name = name;
        _forRoom = forRoom;

        verticalScrollPolicy = ScrollPolicy.OFF;
        horizontalScrollPolicy = ScrollPolicy.OFF;

        setStyle("borderThickness", 0);
        setStyle("borderStyle", "none");
        mouseEnabled = false;

        // but the mouse is still enable on some children..
        addEventListener(MouseEvent.CLICK, handleClick);
        addEventListener(MouseEvent.ROLL_OVER, handleRoll);
        addEventListener(MouseEvent.ROLL_OUT, handleRoll);
    }

    // from NameLabel
    public function setStatus (status :String) :void
    {
        // translate the PlayerList status into an OccupantInfo status
        var occStatus :int;
        switch (status) {
        default:
            Log.dumpStack();
            // but fall through to STATUS_vNORMAL

        case PlayerList.STATUS_NORMAL:
        case PlayerList.STATUS_UNINITIALIZED:
            occStatus = OccupantInfo.ACTIVE;
            break;

        case PlayerList.STATUS_IDLE:
            occStatus = OccupantInfo.IDLE;
            break;

        case PlayerList.STATUS_GONE:
            occStatus = OccupantInfo.DISCONNECTED;
            break;
        }

        // and show uninitialized-ness with italics
        var italicize :Boolean = (status == PlayerList.STATUS_UNINITIALIZED);

        _label.setStatus(occStatus, false, italicize);
    }

    override protected function createChildren () :void
    {
        super.createChildren();

        addChild(MediaWrapper.createView(_name.getPhoto(), MediaDescSize.QUARTER_THUMBNAIL_SIZE));

        _label = new OrthNameLabel();
        _label.setName(_name.toString());
        addChild(new FlexWrapper(_label));
    }

    protected function handleClick (event :MouseEvent) :void
    {
        var menuItems :Array = [];
        var ctrl :WorldController = inject(WorldController);
        var panel :TopPanel = inject(TopPanel);

        ctrl.addMemberMenuItems(_name, menuItems, _forRoom);
        CommandMenu.createMenu(menuItems, panel).popUpAtMouse();
    }

    protected function handleRoll (event :MouseEvent) :void
    {
        var ctrl :RoomObjectController = inject(RoomObjectController);
        // ORTH TODO: make sure inject() can create nulls
        if (ctrl != null) {
            ctrl.setHoverName(_name, (event.type == MouseEvent.ROLL_OVER));
        }
    }

    protected var _name :VizPlayerName;
    protected var _forRoom :Boolean;
    protected var _label :OrthNameLabel;
}
