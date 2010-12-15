//
// $Id: OrthNameLabelCreator.as 19754 2010-12-07 16:19:29Z zell $

package com.threerings.orth.ui {

import com.threerings.util.Log;
import com.threerings.util.Name;

import com.whirled.ui.NameLabel;
import com.whirled.ui.NameLabelCreator;

import com.threerings.orth.client.OrthContext;

import com.threerings.orth.data.VizOrthName;

public class OrthNameLabelCreator
    implements NameLabelCreator
{
    public function OrthNameLabelCreator (mctx :OrthContext, forRoom :Boolean = false)
    {
        _mctx = mctx;
        _forRoom = forRoom;
    }

    // from NameLabelCreator
    public function createLabel (name :Name) :NameLabel
    {
        if (!(name is VizOrthName)) {
            Log.getLog(this).warning("OrthNameLabelCreator only supports VizOrthName");
            return null;
        }

        return new LabelBox(_mctx, name as VizOrthName, _forRoom);
    }

    protected var _mctx :OrthContext;

    protected var _forRoom :Boolean;
}
}

import flash.events.MouseEvent;

import flash.text.TextFieldAutoSize;

import mx.containers.HBox;

import mx.core.ScrollPolicy;

import com.threerings.util.Log;

import com.whirled.ui.NameLabel;
import com.whirled.ui.PlayerList;

import com.threerings.flex.CommandMenu;
import com.threerings.flex.FlexWrapper;

import com.threerings.crowd.data.OccupantInfo;

import com.threerings.orth.client.OrthContext;
import com.threerings.orth.data.MediaDescSize;
import com.threerings.orth.data.VizOrthName;
import com.threerings.orth.ui.MediaWrapper;
import com.threerings.orth.ui.OrthNameLabel;

import com.threerings.orth.room.client.RoomObjectView;

class LabelBox extends HBox
    implements NameLabel
{
    public function LabelBox (
        mctx :OrthContext, name :VizOrthName, forRoom :Boolean)
    {
        _mctx = mctx;
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
            // but fall through to STATUS_NORMAL

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
        _mctx.getOrthController().addMemberMenuItems(_name, menuItems, _forRoom);
        CommandMenu.createMenu(menuItems, _mctx.getTopPanel()).popUpAtMouse();
    }

    protected function handleRoll (event :MouseEvent) :void
    {
        var view :Object = _mctx.getPlaceView();
        if (view is RoomObjectView) {
            (view as RoomObjectView).getRoomObjectController().setHoverName(
                _name, (event.type == MouseEvent.ROLL_OVER));
        }
    }

    protected var _mctx :OrthContext;
    protected var _name :VizOrthName;
    protected var _forRoom :Boolean;
    protected var _label :OrthNameLabel;
}
