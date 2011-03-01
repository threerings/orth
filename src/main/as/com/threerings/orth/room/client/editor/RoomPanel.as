//
// $Id: RoomPanel.as 18260 2009-10-05 19:21:11Z jamie $

package com.threerings.orth.room.client.editor {

import flash.events.Event;

import mx.containers.HBox;
import mx.controls.TextInput;
import mx.controls.ToggleButtonBar;
import mx.events.FlexEvent;
import mx.events.ItemClickEvent;

import com.threerings.flex.CommandButton;
import com.threerings.msoy.data.MemberObject;

import com.threerings.util.Log;
import com.threerings.util.Util;

import com.threerings.orth.client.Msgs;
import com.threerings.orth.data.OrthCodes;
import com.threerings.orth.room.data.FurniData;
import com.threerings.orth.room.data.OrthScene;
import com.threerings.orth.room.data.OrthSceneModel;

/**
 * Displays details about the room.
 */
public class RoomPanel extends BasePanel
{
    // @Override from BasePanel
    override public function updateDisplay (data :FurniData) :void
    {
        super.updateDisplay(data);

        // ignore furni data - we don't care about which furni is selected,
        // only care about the room itself

        if (_controller.scene != null) {
            _name.text = _controller.scene.getName();
            updateAccessButtons();
            this.enabled = true; // override base changes
        }
    }

    public function setHomeButtonEnabled (enabled :Boolean) :void
    {
        if (_homeButton != null) {
            _homeButton.enabled = enabled;
        }
    }

    // @Override from superclass
    override protected function createChildren () :void
    {
        super.createChildren();

        // contains the room name and some buttons
        var box :HBox = new HBox();
        box.setStyle("horizontalGap", 4);
        box.percentWidth = 100;
        addChild(box);

        _name = new TextInput();
        _name.percentWidth = 100;
        _name.maxChars = OrthSceneModel.MAX_NAME_LENGTH;
        box.addChild(_name);

        _buttonbar = new ToggleButtonBar();
        _buttonbar.styleName = "roomEditAccessButtons";
        box.addChild(_buttonbar);

        addChild(makeApplyButtons());
    }

    // @Override from superclass
    override protected function childrenCreated () :void
    {
        super.childrenCreated();

        _buttonbar.addEventListener(ItemClickEvent.ITEM_CLICK, applyHandler);
        _name.addEventListener(Event.CHANGE, changedHandler);
        _name.addEventListener(FlexEvent.ENTER, applyHandler);
    }

    // @Override from BasePanel
    override protected function applyChanges () :void
    {
        super.applyChanges();

        var model :OrthSceneModel = _controller.scene.getSceneModel() as OrthSceneModel;
        if (_name.text != model.name || _buttonbar.selectedIndex != model.accessControl) {
            // configure an update
            var newscene :OrthScene = _controller.scene.clone() as OrthScene;
            var newmodel :OrthSceneModel = newscene.getSceneModel() as OrthSceneModel;
            newmodel.name = (isRoomNameValid() ? _name.text : model.name);
            newmodel.accessControl = _buttonbar.selectedIndex;
            _controller.updateScene(_controller.scene, newscene);
        }
    }

    // @Override from BasePanel
    override protected function changedHandler (event :Event) :void
    {
        // note: no call to super, this is a complete replacement

        // only display apply/cancel buttons if the name field is valid
        if (isRoomNameValid()) {
            setChanged(true);
        }
    }

    protected function isRoomNameValid () :Boolean
    {
        return _name != null &&
            _name.text.length > 0 &&
            _name.text.length < 255;
    }

    protected function updateAccessButtons () :void
    {
        if (_controller.scene == null) {
            return; // nothing to do
        }

        var model :OrthSceneModel = _controller.scene.getSceneModel() as OrthSceneModel;
        if (_buttonbar.dataProvider == null) {
            var defs :Array = new Array();
            for each (var ii :int in ACCESSES) {
                var tip :String = Msgs.EDITING.get("m.access_" + model.ownerType + "_" + ii);
                defs.push({ id: ii, icon: ICONS[ii], toolTip: tip });
            }
            _buttonbar.dataProvider = defs;
        }
        _buttonbar.selectedIndex = model.accessControl;
    }

    private const log :Log = Log.getLog(this);

    protected var _name :TextInput;
    protected var _buttonbar :ToggleButtonBar;
    protected var _homeButton :CommandButton;

    protected const ACCESSES :Array = [
        OrthSceneModel.ACCESS_EVERYONE,
        OrthSceneModel.ACCSS_OWNER_AND_FRIENDS,
        OrthSceneModel.ACCESS_OWNER_ONLY
    ];

    protected const ICONS :Array = [
        inject(OrthResourceFactory).edButtonAccessEveryone,
        inject(OrthResourceFactory).edButtonAccessOwnerAndFriends,
        inject(OrthResourceFactory).edButtonAccessOwnerOnly
    ];
}
}
