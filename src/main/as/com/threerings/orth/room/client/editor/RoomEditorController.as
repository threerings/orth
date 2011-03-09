//
// $Id: RoomEditorController.as 19622 2010-11-23 22:59:49Z zell $

package com.threerings.orth.room.client.editor {
import com.threerings.orth.client.OrthResourceFactory;

import flash.events.MouseEvent;

import flashx.funk.ioc.Module;
import flashx.funk.ioc.inject;

import com.threerings.whirled.client.SceneDirector;
import com.threerings.whirled.data.SceneUpdate;

import com.threerings.io.TypedArray;

import com.threerings.util.ArrayUtil;
import com.threerings.util.Log;
import com.threerings.util.Map;
import com.threerings.util.Maps;
import com.threerings.util.StringUtil;
import com.threerings.util.Util;

import com.threerings.orth.client.Msgs;
import com.threerings.orth.client.OrthContext;
import com.threerings.orth.client.TopPanel;
import com.threerings.orth.entity.client.EntitySprite;
import com.threerings.orth.entity.client.FurniSprite;
import com.threerings.orth.room.client.RoomObjectController;
import com.threerings.orth.room.client.RoomObjectView;
import com.threerings.orth.room.client.updates.FurniUpdateAction;
import com.threerings.orth.room.client.updates.SceneUpdateAction;
import com.threerings.orth.room.data.EntityIdent;
import com.threerings.orth.room.data.EntityType;
import com.threerings.orth.room.data.FurniAction;
import com.threerings.orth.room.data.FurniData;
import com.threerings.orth.room.data.FurniUpdate_Add;
import com.threerings.orth.room.data.FurniUpdate_Change;
import com.threerings.orth.room.data.FurniUpdate_Remove;
import com.threerings.orth.room.data.OrthLocation;
import com.threerings.orth.room.data.OrthScene;
import com.threerings.orth.room.data.OrthSceneModel;
import com.threerings.orth.room.data.SceneAttrsUpdate;

/**
 * Controller for the room editing panel. It starts up two different types of UI: one is
 * a regular Flex window with buttons like "delete" and "undo", and the other is a furni editor,
 * displayed as a border around the targeted furni with grabable hotspots to manipulate it.
 */
public class RoomEditorController
{
    public function initRoomEditorController (view :RoomObjectView) :void
    {
        _view = view;

        _edit = new FurniEditor(this);
        _hover = new FurniHighlight(this);
    }

    public function get rsrc () :OrthResourceFactory
    {
        return _rsrcFactory;
    }

    public function get roomView () :RoomObjectView
    {
        return _view;
    }

    public function get topPanel () :TopPanel
    {
        return _topPanel;
    }

    public function get scene () :OrthScene
    {
        return _sceneDir.getScene() as OrthScene;
    }

    /**
     * Returns true if the room is currently being edited.
     */
    public function isEditing () :Boolean
    {
        return _view != null && _panel != null && _panel.isOpen();
    }

    /**
     * Initializes all editing UIs and starts editing the room.
     */
    public function startEditing (wrapupFn :Function) :void
    {
        if (_view == null) {
            log.warning("Cannot edit a null room view!");
        }

        _panel = _module.getInstance(RoomEditorPanel);
        _wrapupFn = wrapupFn;

        _view.setEditing(true);
        _edit.start();
        _hover.start();
        _panel.open();

        // listen for mouse down
        _view.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);

        // clear out the names cache, and ping the server
        _names.clear();
        queryServerForNames(this.scene.getFurni());

        // make the fake entrance
        _entranceSprite = _module.getInstance(EntranceSprite);
        _entranceSprite.initEntranceSprite(scene.getEntrance());
        _entranceSprite.setEditing(true);
        _view.addOtherSprite(_entranceSprite);
        var id :EntityIdent = _entranceSprite.getFurniData().item;
        _names.put(id, { label: Msgs.EDITING.get("l.entrance"), data: id });

        _panel.setDecor(scene.getDecor());

        // hide advanced ui
        actionAdvancedEditing(false);
        updateNameDisplay();
    }

    /**
     * Called by the room controller to close the editor.
     */
    public function endEditing () :void
    {
        // tell the panel to close
        _panel.close();

        // note: this function does *not* get called when the player closes the editor by
        // clicking on the close button. all significant editor cleanup should happen in
        // actionEditorClosed()
    }

    /**
     * Receives a scene update from the controller, and refreshes the edited target appropriately.
     */
    public function processUpdate (update :SceneUpdate) :void
    {
        if (! isEditing()) {
            // don't care about updates if we're not actually editing.
            return;
        }

        if (update is SceneAttrsUpdate) {
            var up :SceneAttrsUpdate = (update as SceneAttrsUpdate);
            // update sprite data
            _entranceSprite.getFurniData().loc.set(up.entrance);
            _entranceSprite.update(_entranceSprite.getFurniData());
            _panel.setDecor(up.decor);
            updateNameDisplay();

            refreshTarget();

        } else if (update is FurniUpdate_Add) {
            queryServerForNames([ (update as FurniUpdate_Add).data ]);
            updateNameDisplay();
            _addCount += 1;

        } else if (update is FurniUpdate_Change) {
            refreshTarget();

        } else if (update is FurniUpdate_Remove) {
            // if the target furni just got removed, we should lose focus.
            if (_edit.target != null && _edit.target.getFurniData().item.equals(
                    (update as FurniUpdate_Remove).data.item)) {
                setTarget(null, null);
            }
            updateNameDisplay();
        }
    }

    /** Called by the controller and other functions, to update the panel's undo button. */
    public function updateUndoStatus (undoAvailable :Boolean) :void
    {
        _panel.updateUndoStatus(undoAvailable);
    }

    /** Called by the targetting system when a target is being selected. */
    public function updateTargetSelected () :void
    {
        _panel.updateTargetSelected(_edit.target);
    }

    /**
     * Called by the targetting system, applies a furni change to the scene.
     */
    public function updateFurni (toRemove :FurniData, toAdd :FurniData) :void
    {
        if (toAdd is EntranceFurniData) {
            // entrace is actually a fake furni, and entrance data lives in the scene model
            var newscene :OrthScene = scene.clone() as OrthScene;
            var newmodel :OrthSceneModel = newscene.getSceneModel() as OrthSceneModel;
            newmodel.entrance = toAdd.loc;
            updateScene(scene, newscene);
        } else {
            // it's a genuine furni update - apply it
            _view.getRoomObjectController().applyUpdate(new FurniUpdateAction(toRemove, toAdd));
        }
        updateUndoStatus(true);
    }

    /**
     * Called by the panel, applies a property change to the scene.
     */
    public function updateScene (oldScene :OrthScene, newScene :OrthScene) :void
    {
        _roomObjCtrl.applyUpdate(new SceneUpdateAction(oldScene, newScene));
        updateUndoStatus(true);
    }

    /**
     * Called by the panel when the name list selection changed, either programmatically
     * or due to user interaction - causes the specified item to be selected as the new target.
     * Note: this searches through the list of sprites; use setTarget() directly if possible.
     */
    public function findAndSetTarget (ident :EntityIdent) :void
    {
        // is this our special entrance sprite? if so, it's not in the room contents list.
        if (ident.equals(EntranceFurniData.ITEM_IDENT)) {
            setTarget(_entranceSprite, null);
            return;
        }

        // it's a bona fide selection. if the new target is different, let's select it
        if (_edit.target == null || ! _edit.target.getFurniData().item.equals(ident)) {
            var sprites :Array = _view.getFurniSprites().values();
            // unfortunately, we have to search through all sprites to find the one we want
            var index :int = ArrayUtil.indexIf(sprites, function (sprite :FurniSprite) :Boolean {
                    return sprite.getFurniData().item.equals(ident);
                });
            setTarget(index == -1 ? null : sprites[index], null);
        }
    }

    /**
     * Called by the room controller, to query whether the user should be allowed to move
     * around the scene.
     */
    public function isMovementEnabled() :Boolean
    {
        return isEditing() && _edit.isIdle();
    }

    /** Performs an Undo action, if possible. */
    public function actionUndo () :void
    {
        // undo the last action, and set undo button's enabled state appropriately
        updateUndoStatus(_view.getRoomObjectController().undoLastUpdate());
    }

    /** Performs a Delete action on the currently selected target. */
    public function actionDelete () :void
    {
        // delete the currently selected item
        if (_edit.target != null) {
            updateFurni(_edit.target.getFurniData(), null);
        }
    }

    /** Adjusts furni size from a panel button action. */
    public function actionAdjustScale (multiplierX :Number, multiplierY :Number) :void
    {
        withFurniUpdate(function () :void {
            if (multiplierX != 1 || multiplierY != 1) {
                var f :FurniData = _edit.target.getFurniData().clone() as FurniData;
                _edit.updateTargetScale(multiplierX * f.scaleX, multiplierY * f.scaleY);
            }
        });
    }

    /** Adjusts furni size from a panel button action. */
    public function actionAdjustRotation (
        rotationDelta :Number, snap :Boolean = false, snapIncrement :Number = 0) :void
    {
        withFurniUpdate(function () :void {
            if (rotationDelta != 0) {
                // rotate the furni
                var f :FurniData = _edit.target.getFurniData();
                var newrotation :Number = f.rotation + rotationDelta;

                // only do this calculation if we're not already snapped
                if (snap && (f.rotation % snapIncrement != 0)) {
                    // use delta to snap to the specified increment
                    var snapfn :Function = (rotationDelta > 0) ? Math.ceil : Math.floor;
                    newrotation = snapIncrement * snapfn(f.rotation / snapIncrement);
                }

                _edit.updateTargetRotation(newrotation);
            }
        });
    }

    /** Adjusts furni location from a panel button action. */
    public function actionAdjustYPosition (yDelta :Number) :void
    {
        withFurniUpdate(function () :void {
            if (yDelta != 0) {
                var f :FurniData = _edit.target.getFurniData().clone() as FurniData;
                _edit.updateTargetLocation(
                    new OrthLocation(f.loc.x, f.loc.y + yDelta, f.loc.z));
            }
        });
    }

    /** Resets the edited furni to the base location, or size, or both. */
    public function actionResetTarget (
        resetLocation :Boolean, resetSize :Boolean, resetRotation :Boolean) :void
    {
        withFurniUpdate(function () :void {
            if (resetLocation) {
                _edit.updateTargetLocation(new OrthLocation(0.5, 0.5, 0.5));
            }
            if (resetSize) {
                _edit.updateTargetScale(1.0, 1.0);
            }
            if (resetRotation) {
                _edit.updateTargetRotation(0);
            }
        });
    }

    /** Tells the room controller to start editing the target as a door. */
    public function actionTargetDoor () :void
    {
        if (_edit.target == null || ! _edit.target.isActionModifiable()) {
            return;
        }

        var data :FurniData = _edit.target.getFurniData();

        // make the furni's type to a portal, and save on the server
        withFurniUpdate(function () :void {
            // ORTH TODO: Figure out how Who can get its WhoFurniActions in here
            data.actionType = FurniAction.NOT_AN_ACTION;
            data.actionData = "" + scene.getId() + ":" + scene.getName();
        });

        // now open up the door creation wizard. note: we're not wrapping this
        // in a furni update, because the room controller code will do that for us.
        _view.getRoomObjectController().handleEditDoor(data);
    }

    /** Starts editing the URL. */
    public function actionTargetLink (url :String, tip :String) :void
    {
        var actionData :String = url;
        tip = StringUtil.trim(tip);
        if (!StringUtil.isBlank(tip)) {
            actionData += "||" + tip;
        }

        // ORTH TODO: Figure out how Who can get its WhoFurniActions in here
        setTargetAction(FurniAction.NOT_AN_ACTION, actionData);
    }

    /** Makes the target into a regular furni. */
    public function actionTargetClear () :void
    {
        // ORTH TODO: Figure out how Who can get its WhoFurniActions in here
        setTargetAction(FurniAction.NOT_AN_ACTION, null);
    }

    /**
     * Cleans up editing actions and closes editing UIs. This function is called automatically
     * when the main editing UI is being closed (whether because the user clicked the close
     * button, or because the room controller cancelled the editing session).
     */
    public function actionEditorClosed () :void
    {
        if (_panel != null && _panel.isOpen()) {
            log.warning("Room editor failed to close!");
        }

        // stop listening for mouse down
        _view.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDown);

        _entranceSprite.setEditing(false);
        _view.removeOtherSprite(_entranceSprite);
        _entranceSprite = null;

        _edit.end();
        _hover.end();
        _view.setEditing(false);

        _wrapupFn();
        _panel = null;
    }

    /** Tells the room controller the user updated advanced editing preferences. */
    public function actionAdvancedEditing (advanced :Boolean) :void
    {
        _edit.setAdvancedMode(advanced);
        _panel.displayAdvancedPanels(advanced);
    }

    // Functions for highlighting targets and displaying the furni editing UI

    /** Called by the room controller, when the user rolls over or out of a valid sprite. */
    public function mouseOverSprite (sprite :EntitySprite) :void
    {
        var sprite :EntitySprite = _edit.isIdle() ? sprite : null;
        if (_hover.target != sprite && (_edit.target != null ? _edit.target != sprite : true)) {
            // either the player is hovering over a new sprite, or switching from an old
            // target to nothing at all. in either case, update!
            _hover.target = sprite as FurniSprite;
        }
    }

    /**
     * Called after target sprite modification, it will update all UIs to update their parameters.
     */
    public function targetSpriteUpdated () :void
    {
        _edit.updateDisplay();
        _panel.updateDisplay(_edit.target);
    }

    /**
     * Handles mouse presses, starts editing furniture.
     */
    protected function mouseDown (event :MouseEvent) :void
    {
        var hit :EntitySprite =
            _view.getRoomController().getHitSprite(event.stageX, event.stageY, true);
        if (hit is FurniSprite) {
            if (_edit.isIdle()) {
                _hover.target = null;
                setTarget(hit as FurniSprite, event);
            }
        }
    }

    /**
     * Wraps the call to /thunk/ in a check for furni existence, and triggers an update
     * to be sent to the server if /thunk/ modified the furni in any way.
     */
    protected function withFurniUpdate (thunk :Function) :void
    {
        if (_edit.target == null) {
            return;
        }

        var original :FurniData = _edit.target.getFurniData().clone() as FurniData;
        thunk();

        var current :FurniData = _edit.target.getFurniData();
        if (! original.equivalent(current)) {
            updateFurni(original, current);
        }
    }

    /**
     * Helper function, returns an array of EntityIdents of pieces of furniture from the specified
     * /furnis/ array, whose names are not stored in the cache.
     */
    protected function findNamelessFurnis (furnis :Array) :TypedArray /* of EntityIdent */
    {
        var idents :TypedArray = TypedArray.create(EntityIdent);
        var ident :EntityIdent;
        for each (var data :FurniData in furnis) {
            ident = data.item;
            // only query for new items
            if (! _names.containsKey(ident)) {
                // skip freebie doors and other fake items
                if (data.item.getType() != EntityType.NOT_A_TYPE) {
                    idents.push(ident);
                }
            }
        }
        return idents;
    }

    /**
     * Given a list of furnis, retrieves names of furnis we don't yet know about.
     */
    protected function queryServerForNames (furnis :Array /* of FurniData */) :void
    {
        if (furnis == null) {
            return; // nothing to do
        }

        // find which furni names we're missing
        var idents :TypedArray = findNamelessFurnis(furnis);

        if (idents.length == 0) {
            return; // no names are missing - we're done!
        }

        // now ask the server for ids
        var resultHandler :Function = function (names :Array /* of String */) :void {
            // we got an array of names! put them all in the cache and update the list.
            for (var i :int = 0; i < idents.length; i++) {
                _names.put(idents[i], { label: names[i], data: idents[i] });
            }
            updateNameDisplay();
        };
        // ORTH TODO: items will be compiled into the client, but we're not sure how yet
//        var svc :ItemService = _client.requireService(ItemService) as ItemService;
//        svc.getItemNames(idents, _octx.resultListener(resultHandler));
    }

    /**
     * When the user clicks on a new item, updates its displayed name.
     */
    protected function selectTargetName () :void
    {
        // if there's no furni selected, we have nothing to do
        if (_edit.target == null) {
            _panel.selectInNameList(null);
            return;
        }

        // pull out selected furni
        var targetData :FurniData = _edit.target.getFurniData();
        var ident :EntityIdent = targetData.item;
        _panel.updateDisplay(_edit.target);

        // if this is a special furni, deal with it in a special way
        if (EntranceFurniData.ITEM_IDENT.equals(ident)) {
            _panel.selectInNameList(_names.get(ident));
            return;
        }

        if (ident.getType() == EntityType.NOT_A_TYPE) {
            // this must be one of the "freebie" doors - since this isn't an actual Item,
            // it has no name.
            _panel.selectInNameList(null);
            return;
        }

        // update display name
        _panel.selectInNameList(_names.get(ident));
    }

    /** Called when the list of objects in the room had changed, it updates the panel. */
    protected function updateNameDisplay () :void
    {
        var idents :Array = this.scene.getFurni().map(
            function(furni :FurniData, i :*, a :*) :EntityIdent {
                return furni.item;
            });
        var defs :Array = _names.values().filter(function (def :Object, ... ignored) :Boolean {
            return ArrayUtil.contains(idents, def.data);
        });

        defs.push(_names.get(EntranceFurniData.ITEM_IDENT));
        defs.sortOn("label", Array.CASEINSENSITIVE);

        _panel.updateNameList(defs);
        selectTargetName();
    }

    /** Sets the currently edited target to the specified sprite. */
    protected function setTarget (targetSprite :FurniSprite, event :MouseEvent) :void
    {
        _edit.target = targetSprite;
        if (event != null) {
            _edit.defaultHotspot.implicitStartAction(event);
        }
        targetSpriteUpdated();
        selectTargetName();
    }

    /** Sets the currently edited target's action (if applicable). */
    protected function setTargetAction (actionType :FurniAction, actionData :String) :void
    {
        withFurniUpdate(function () :void {
            if (_edit.target == null || ! _edit.target.isActionModifiable()) {
                return;
            }

            var data :FurniData = _edit.target.getFurniData();
            data.actionType = actionType;
            data.actionData = actionData;
        });
    }

    /** Forces the target sprite to be re-read from the room. */
    protected function refreshTarget () :void
    {
        // if the player selected the singleton entrance sprite, our work is done
        if (_edit.target is EntranceSprite) {
            setTarget(_entranceSprite, null);
            return;
        }

        // otherwise, try to find the right sprite in the room, and refresh the target from that
        if (_edit.target != null) {
            var sprites :Map = _view.getFurniSprites();
            setTarget(sprites.get(_edit.target.getFurniData().id) as FurniSprite, null);
        } else {
            targetSpriteUpdated();
        }
    }

    protected var _view :RoomObjectView;
    protected var _edit :FurniEditor;
    protected var _hover :FurniHighlight;
    protected var _panel :RoomEditorPanel;
    protected var _wrapupFn :Function;   // will be called when ending editing

    /**
     * Mapping from EntityIdents to combo box entries that contain names and EntityIdents. This
     * cache is updated once when the editor is opened, and then following each furni update.
     */
    protected var _names :Map = Maps.newMapOf(EntityIdent);

    protected var _entranceSprite :EntranceSprite;

    /** Tracks how many items have been added to the room this session. */
    protected var _addCount :int;

    protected const _octx :OrthContext = inject(OrthContext);
    protected const _module :Module = inject(Module);
    protected const _roomObjCtrl :RoomObjectController = inject(RoomObjectController);
    protected const _sceneDir :SceneDirector = inject(SceneDirector);
    protected const _topPanel :TopPanel = inject(TopPanel);

    protected const _rsrcFactory :OrthResourceFactory = inject(OrthResourceFactory);

    private const log :Log = Log.getLog(this);
}
}
