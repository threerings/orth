//
// $Id: DoorTargetEditController.as 18321 2009-10-09 23:04:55Z jamie $

package com.threerings.orth.room.client.editor {

import mx.containers.Canvas;
import mx.core.Container;

import com.threerings.util.Log;

import com.threerings.flex.CommandButton;
import com.threerings.flex.FlexUtil;

import com.threerings.whirled.client.SceneDirector;
import com.threerings.whirled.data.Scene;

import com.threerings.orth.client.HeaderBar;
import com.threerings.orth.client.Msgs;

import com.threerings.orth.room.client.editor.ui.FloatingPanel;
import com.threerings.orth.room.client.RoomContext;

import com.threerings.orth.room.client.RoomObjectController;
import com.threerings.orth.room.client.updates.FurniUpdateAction;
import com.threerings.orth.room.data.FurniData;
import com.threerings.orth.room.data.OrthLocation;
import com.threerings.orth.room.data.OrthScene;

/**
 * This controller handles in-world door editing. The player picks a door to edit, then travels
 * the whirled in search of a target room. Once target is selected, the player will be returned
 * to the door location, and the door will be set to point to the target scene.
 *
 * Note: this object is a singleton, because it needs to exist independently of the different
 * room views that get created when player moves between scenes.
 */
public class DoorTargetEditController
{
    /**
     * Singleton constructor. Do not instantiate the singleton directly - use the static
     * function start() instead.
     */
    public function DoorTargetEditController ()
    {
        // this would be simpler if Actionscript supported non-public constructors. why doesn't it?
        if (_this != null) {
            throw new Error("DoorTargetEditController must not be instantiated directly.");
        }
    }

    /** Returns true if a door is currently being edited. */
    public static function get editing () :Boolean
    {
        return (_this._doorScene != 0);
    }

    /**
     * Returns true if a door is currently being edited, and we're in the middle of
     * committing a new door target selection.
     */
    protected static function get committing () :Boolean
    {
        return editing && (_this._destinationScene != 0);
    }

    /**
     * Start editing a door. Displays the target editor window, which waits for the player to click
     * on a 'submit' button to specify target location.
     */
    public static function start (doorData :FurniData, ctx :RoomContext) :void
    {
        if (editing) {
            _this.deinit();
        } else {
            _this.init(doorData, ctx);
        }
    }

    /**
     * Initializes all internal data structures.
     */
    protected function init (doorData :FurniData, ctx :RoomContext) :void
    {
        _ctx = ctx;
        _container = ctx.getTopPanel().getPlaceContainer();
        _ui = makeUI();
        _ui.open();
        _ui.x = 5;
        _ui.y = HeaderBar.getHeight(ctx.getMsoyClient()) + 5;

        _doorScene = _ctx.getSceneDirector().getScene().getId();
        _doorId = doorData.itemId;

        _destinationScene = 0;
        _destinationLoc = null;
        _destinationName = null;
    }

    /**
     * Shuts down any editing data structures.
     */
    protected function deinit (doorData :FurniData = null) :void
    {
        // if we got update info...
        if (doorData != null) {
            // ...create a furni update based on the door data, and send it to the server.
            var ctrl :RoomObjectController =
                _ctx.getLocationDirector().getPlaceController() as RoomObjectController;

            var newdata :FurniData = doorData.clone() as FurniData;
            // note: the destinationName may have colons in it, so we split with care in FurniData
            newdata.actionData = _destinationScene + ":" + roundCoord(_destinationLoc.x) + ":" +
                roundCoord(_destinationLoc.y) + ":" +  roundCoord(_destinationLoc.z) + ":" +
                _destinationLoc.orient + ":" + _destinationName;

            ctrl.applyUpdate(new FurniUpdateAction(_ctx, doorData, newdata));
        }

        // now clean up
        _doorId = _doorScene = _destinationScene = 0;
        _destinationLoc = null;
        _destinationName = null;

        _ui.close();
        _ui = null;
        _container = null;
        _ctx = null;
    }

    /** Used to round locations to nearest hundredths to avoid giant actionData strings. */
    protected function roundCoord (value :Number) :String
    {
        var str :String = String(value);
        // remove any leading 0 for brevity
        if (str.length > 1 && str.charAt(0) == "0") {
            str = str.substring(1);
        }
        var period :int = str.lastIndexOf(".");
        if (period != -1) {
            str = str.substring(0, Math.min(period + 3, str.length));
        }
        return str;
    }

    /** Creates the UI. */
    protected function makeUI () :FloatingPanel
    {
        var panel :FloatingPanel = new FloatingPanel(_ctx, Msgs.EDITING.get("t.edit_door"));
        panel.setButtonWidth(0);
        panel.showCloseButton = true;

        panel.addChild(FlexUtil.createText(Msgs.EDITING.get("m.edit_door"), 400));

        var showRooms :CommandButton = new CommandButton(Msgs.EDITING.get("b.show_rooms"),
            _ctx.getWorldController().displayPage, [ "people", "rooms_" + _ctx.getMyId() ]);
        showRooms.styleName = "orangeButton";
        panel.addChild(showRooms);

        panel.addButtons(new CommandButton(Msgs.EDITING.get("b.set_door"), setTarget));

        return panel;
    }

    /**
     * Called when the player hits the 'b.set_door' button.
     */
    protected function setTarget () :void
    {
        var sd :SceneDirector = _ctx.getSceneDirector();
        if (sd != null) {
            // the door should point to where we are right now
            setDoor(sd.getScene().getId());
        }
    }

    /**
     * Given the target scene Id, this function starts the chain of events that will
     * set the door target and move the player back to the room where the door was.
     */
    protected function setDoor (targetSceneId :int) :void
    {
        // the sequence of events started by this function is as follows:
        // 1. we remember the current scene as the new target, and issue a request
        //    to transfer the player back to the scene with the door.
        // 2. once we've traveled there, we set the door target to point to the new location.
        //
        // this baroque order of operations reflects a usage pattern in our code,
        // which requires that a scene be loaded up before it can be edited.

        var sd :SceneDirector = _ctx.getSceneDirector();
        if (sd == null) {
            Log.getLog(this).warning("Room purchase failure: scene director not initialized.");
            return;
        }

        var scene :OrthScene = sd.getScene() as OrthScene;

        // remember the target
        _destinationScene = targetSceneId;
        _destinationLoc = _ctx.getSpotSceneDirector().getIntendedLocation() as OrthLocation;
        _destinationName = _ctx.getSceneDirector().getScene().getName();

        // are we already in the room with the door?
        if (scene.getId() == _doorScene) {
            // get ready to rock!
            finalizeCommit(scene);

        } else {
            // move the player back to the room with the door
            sd.moveTo(_doorScene);
            // the rest will be triggered via updateLocation(), once we get there...
        }
    }

    /**
     * Called when the player enters a new room. If we're committing a door, and we
     * just traveled to the room where the door was placed, finish up editing.
     */
    public static function updateLocation () :void
    {
        // we only care about this if we're actually in the process of setting a target door
        if (committing) {
            var scene :OrthScene = _this._ctx.getSceneDirector().getScene() as OrthScene;

            // if we're editing, and we traversed back to the original door location,
            // update the door and end editing.
            if (scene.getId() == _this._doorScene) {
                _this.finalizeCommit(scene);
            }
        }
    }

    /**
     * Called after we've returned to the room with the door, will set the door's target.
     */
    protected function finalizeCommit (scene :OrthScene) :void
    {
        // find the door furni
        var furnis :Array = scene.getFurni();
        for each (var data :FurniData in furnis) {
            // check to make sure the object still exists there, and is still a door.
            // todo: we probably want some kind of a lock here.
            if (data.itemId == _doorId && data.actionType == FurniData.ACTION_PORTAL) {
                deinit(data);
                return;
            }
        }

        // the door went away? just cancel.
        deinit();
    }

    /** Singleton constant. */
    protected static var _this :DoorTargetEditController = new DoorTargetEditController();

    /** Scene ID where the door resides. */
    protected var _doorScene :int = 0;

    /** Item ID of the door. */
    protected var _doorId :int = 0;

    /** Scene ID of the door destination. */
    protected var _destinationScene :int = 0;

    /** The location at which to arrive in our destination. */
    protected var _destinationLoc :OrthLocation;

    /** The name of the destination scene. */
    protected var _destinationName :String;

    /** Flex container for the scene. */
    protected var _container :Container;

    /** World context, what else? */
    protected var _ctx :RoomContext;

    /** Canvas that contains the editing UI. */
    protected var _ui :FloatingPanel;
}
}

