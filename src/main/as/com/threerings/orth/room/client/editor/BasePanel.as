//
// $Id: BasePanel.as 14724 2009-02-09 00:56:09Z ray $

package com.threerings.orth.room.client.editor {

import flash.events.Event;

import mx.containers.HBox;
import mx.containers.VBox;
import mx.core.Container;

import com.threerings.flex.CommandButton;
import com.threerings.orth.client.Msgs;
import com.threerings.orth.room.data.FurniData;

/**
 * Basic panel that displays apply and cancel buttons, and sends updates to the controller.
 */
public class BasePanel extends VBox
{
    public function BasePanel (controller :RoomEditorController)
    {
        _controller = controller;
        this.percentWidth = 100;
    }

    /**
     * Updates the UI from furni data. Data can be null, in which case the panel
     * will be disabled. */
    public function updateDisplay (data :FurniData) :void
    {
        if (data == null) {
            this.enabled = false;
            _furniData = null;

        } else {
            this.enabled = true;
            _furniData = data.clone() as FurniData;
        }

        // whatever edits were pending, they will be gone by the time the subclass is done
        // with this update. so just disable the buttons.
        setChanged(false);
    }

    /** Creates the apply/cancel buttons which are magically shown and hidden when we're changed. */
    protected function makeApplyButtons () :Container
    {
        _applyButton = new CommandButton(Msgs.EDITING.get("b.apply"), applyChanges);
        _applyButton.styleName = "roomEditPanelButton";
        _applyButton.height = 20;
        _cancelButton = new CommandButton(Msgs.EDITING.get("b.cancel"), revertChanges);
        _cancelButton.styleName = "roomEditPanelButton";
        _cancelButton.height = 20;

        _buttons = new HBox();
        _buttons.addChild(_cancelButton);
        _buttons.addChild(_applyButton);
        _buttons.visible = _buttons.includeInLayout = false;
        setChanged(true);
        return _buttons;
    }

    // @Override from superclass
    override protected function childrenCreated () :void
    {
        super.childrenCreated();

        updateDisplay(null);
        setChanged(false);
    }

    /**
     * Copies action data from the UI based on action type, and if the data is different,
     * creates a new FurniData with changes applied. Subclasses should override this function
     * to provide their own data updates.
     */
    protected function getUserModifications () :FurniData
    {
        // subclasses, do something here!
        return null;
    }

    /** Applies changes to the currently targetted object. */
    protected function applyChanges () :void
    {
        var newData :FurniData = getUserModifications();
        if (newData != null) {
            _controller.updateFurni(_furniData, newData);
        }
        setChanged(false);
    }

    /** Reverts changes by re-reading from the original furni data. */
    protected function revertChanges () :void
    {
        updateDisplay(_furniData);
    }

    /** Enables or disables the "apply" and "cancel" buttons, based on UI changes. */
    protected function setChanged (newValue :Boolean) :void
    {
        if (_buttons != null && newValue != _buttons.visible) {
            _buttons.visible = _buttons.includeInLayout = newValue;
        }
    }

    /** Event handler for widgets; enables the "apply" and "cancel" buttons. */
    protected function changedHandler (event :Event) :void
    {
        setChanged(true);
    }

    /** Event handler for widgets; saves updates, just like clicking the "apply" button. */
    protected function applyHandler (event :Event) :void
    {
        applyChanges();
    }

    protected var _furniData :FurniData;
    protected var _controller :RoomEditorController;
    protected var _buttons :HBox;
    protected var _buttonsEnabled :Boolean;
    protected var _applyButton :CommandButton;
    protected var _cancelButton :CommandButton;
}

}
