//
// $Id: RoomView.as 18849 2009-12-14 20:14:44Z ray $

package com.threerings.orth.room.client {
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.ui.Mouse;
import flash.utils.ByteArray;

import flashx.funk.ioc.inject;
import flashx.funk.util.isAbstract;

import com.threerings.crowd.data.PlaceObject;
import com.threerings.whirled.spot.data.Location;
import com.threerings.whirled.spot.data.Portal;

import com.threerings.util.ArrayUtil;
import com.threerings.util.Iterator;
import com.threerings.util.Log;
import com.threerings.util.Map;
import com.threerings.util.Maps;
import com.threerings.util.Name;
import com.threerings.util.NamedValueEvent;
import com.threerings.util.ObjectMarshaller;

import com.threerings.orth.chat.client.ChatInfoProvider;
import com.threerings.orth.chat.client.SpeakerObserver;
import com.threerings.orth.client.ContextMenuProvider;
import com.threerings.orth.client.OrthPlaceView;
import com.threerings.orth.client.Prefs;
import com.threerings.orth.client.SnapshotUtil;
import com.threerings.orth.client.Snapshottable;
import com.threerings.orth.client.TopPanel;
import com.threerings.orth.data.MediaMimeTypes;
import com.threerings.orth.entity.client.EntitySprite;
import com.threerings.orth.entity.client.FurniSprite;
import com.threerings.orth.entity.client.MemberSprite;
import com.threerings.orth.entity.client.OccupantSprite;
import com.threerings.orth.entity.client.ParallaxSprite;
import com.threerings.orth.entity.data.Walkability;
import com.threerings.orth.room.client.layout.RoomLayout;
import com.threerings.orth.room.client.layout.RoomLayoutFactory;
import com.threerings.orth.room.data.Decor;
import com.threerings.orth.room.data.EntityIdent;
import com.threerings.orth.room.data.FurniData;
import com.threerings.orth.room.data.OrthLocation;
import com.threerings.orth.room.data.OrthScene;

/**
 * The base room view. Should not contain any RoomObject or other network-specific crap.
 */
public class RoomView extends Sprite
    implements ContextMenuProvider, Snapshottable, ChatInfoProvider
{
    /** Logging facilities. */
    protected static const log :Log = Log.getLog(RoomView);

    /**
     * Constructor.
     */
    public function RoomView (ctx :RoomContext, ctrl :RoomController)
    {
        _ctx = ctx;
        _ctrl = ctrl;
        _layout = RoomLayoutFactory.createLayout(null, this);
    }

    /**
     * Returns the room controller.
     */
    public function getRoomController () :RoomController
    {
        return _ctrl;
    }

    /**
     * Returns the layout object responsible for room layout.
     */
    public function get layout () :RoomLayout
    {
        return _layout;
    }

    /**
     * Returns the metrics object with geometry information from the scene.
     */
    public function get metrics () :RoomMetrics
    {
        return _layout.metrics;
    }

    // from OrthPlaceView
    public function getPlaceName () :String
    {
        return (_scene != null) ? _scene.getName() : null;
    }

    // from Snapshottable
    public function snapshot (
        bitmapData :BitmapData, matrix :Matrix, childPredicate :Function = null) :Boolean
    {
        return SnapshotUtil.snapshot(this, bitmapData, matrix, childPredicate);
    }

    // from ChatInfoProvider
    public function getBubblePosition (speaker:Name):Point
    {
        return isAbstract();
    }

    // from ChatInfoProvider
    public function addBubbleObserver (observer:SpeakerObserver):void
    {
        isAbstract();
    }

    // from ChatInfoProvider
    public function removeBubbleObserver (observer:SpeakerObserver):void
    {
        isAbstract();
    }

    /**
     * Effect the global hover of furni.
     */
    public function hoverAllFurni (on :Boolean) :void
    {
        for each (var sprite :FurniSprite in _furni.values()) {
            doGlobalHover(sprite, on);
        }
    }

    // from ContextMenuProvider
    public function populateContextMenu (menuItems :Array) :void
    {
        var hit :* = _ctrl.getHitSprite(stage.mouseX, stage.mouseY, true);
        if (hit === undefined) {
            return;
        }
        var sprite :EntitySprite = (hit as EntitySprite);
        if (sprite != null) {
            populateSpriteContextMenu(sprite, menuItems);
        }
    }

    /**
     * Called by EntitySprite instances when they've had their location updated.
     */
    public function locationUpdated (sprite :EntitySprite) :void
    {
        _layout.updateScreenLocation(sprite, sprite.getLayoutHotSpot());
    }

    /**
     * A convenience function to get our personal avatar.
     */
    public function getMyAvatar () :MemberSprite
    {
        // see subclasses
        return null;
    }

    /**
     * Get the actions currently published by our own avatar.
     */
    public function getMyActions () :Array
    {
        var avatar :MemberSprite = getMyAvatar();
        return (avatar != null) ? avatar.getAvatarActions() : [];
    }

    /**
     * Get the states currently published by our own avatar.
     */
    public function getMyStates () :Array
    {
        var avatar :MemberSprite = getMyAvatar();
        return (avatar != null) ? avatar.getAvatarStates() : [];
    }

    /**
     * Return the current location of the avatar that represents our body.
     */
    public function getMyCurrentLocation () :OrthLocation
    {
        var avatar :MemberSprite = getMyAvatar();
        if (avatar != null) {
            return avatar.getLocation();
        } else {
            return new OrthLocation(-1, -1, -1);
        }
    }

    /**
     * Get the w/h/d of the current room.
     */
    public function getRoomBounds () :Array
    {
        return [ _layout.metrics.sceneWidth, _layout.metrics.sceneHeight,
           _layout.metrics.sceneDepth ];
    }

    public function getMemories (ident :EntityIdent) :Object
    {
        return {};
    }

    public function lookupMemory (ident :EntityIdent, key :String) :Object
    {
        return null;
    }

    /**
     * A callback from occupant sprites.
     */
    public function moveFinished (sprite :OccupantSprite) :void
    {
        if (null != _pendingRemovals.remove(sprite.getOid())) {
            // trigger a portal traversal
            portalTraversed(sprite.getLocation(), false);
            // and remove the sprite
            dispatchEntityLeft(sprite.getEntityIdent());
            removeSprite(sprite);
        }
    }

    /**
     * Let this object know at what offset it's currently being viewed; used for e.g. Parallax
     * adjustments.
     */
    public function notifyScroll (offset :Point) :void
    {
        _scrollOffset = offset;

        forEachEntity(function (key :Object, sprite :EntitySprite) :void {
            if (sprite is ParallaxSprite) {
                relayoutSprite(sprite);
            }
        });
    }

    /**
     * Get the current scroll value.
     */
    public function getScrollOffset () :Point
    {
        return _scrollOffset;
    }

    public function dimAvatars (setDim :Boolean) :void
    {
        setActive(_occupants, !setDim);
        setActive(_pendingRemovals, !setDim);
    }

    public function dimFurni (setDim :Boolean) :void
    {
        setActive(_furni, !setDim);
    }

    /**
     * Given a newly-initialized FurniData, insert a guess for the initial location.
     */
    public function setInitialFurniLocation (furni :FurniData) :void
    {
        var x :Number = .5;
        var y :Number = 0;
        var z :Number = 0;
        // TODO: this >0 check is used elsewhere, but it prevents 0,0 from being valid.
        if (furni.hotSpotY > 0 || furni.hotSpotX > 0) {
            // Crap. We don't know the actual dimensions of the media yet, so we can't
            // make a reasonable guess for a height. But we can at least make it visible.
            // We can't even wait for the media dimensions because this gets saved immediately
            // in the case of new furni being added to a room.
            // Since it has a y hotspot of 0 it's probably something like a carpet, so adjust
            // the Z rather than the Y.
            if (furni.hotSpotY == 0) {
                z = .5;
            }
        }
        furni.loc = new OrthLocation(x, y, z);
    }

    public function addElement (element :RoomElement) :void
    {
        addChild(element.getVisualization());
        addToElementMap(element);
    }

    public function appendElement (element :RoomElement) :void
    {
        addChildAt(element.getVisualization(), numChildren);
        addToElementMap(element);
    }

    public function removeElement (element :RoomElement) :void
    {
        removeChild(element.getVisualization());
        removeFromElementMap(element);
    }

    public function vizToEntity (viz :DisplayObject) :RoomElement
    {
        return _elements.get(viz);
    }

    /**
     * Add the specified sprite to this display and have the room track it.
     */
    public function addOtherSprite (sprite :EntitySprite) :void
    {
        _otherSprites.push(sprite);
        addSprite(sprite);
        relayoutSprite(sprite);
    }

    /**
     * Remove the specified sprite.
     */
    public function removeOtherSprite (sprite :EntitySprite) :void
    {
        ArrayUtil.removeAll(_otherSprites, sprite);
        removeSprite(sprite);
    }

    // documentation inherited from interface PlaceView
    public function willEnterPlace (plobj :PlaceObject) :void
    {
        // nada
    }

    // documentation inherited from interface PlaceView
    public function didLeavePlace (plobj :PlaceObject) :void
    {
        removeAll(_furni);
        _scene = null;

        Mouse.show(); // re-show the mouse, in case something hid it
    }

    /**
     * Set the scene to be displayed.
     */
    public function setScene (scene :OrthScene) :void
    {
        _scene = scene;
        updateLayout(scene.getDecor());
        _backdrop.update(scene.getDecor());
        relayout();
    }

    public function getScene () :OrthScene
    {
        return _scene;
    }

    // ORTH TODO: once this uses logical coordinates, it really belongs in the controller
    public function canWalkTo (toLoc :OrthLocation) :Boolean
    {
        var myLoc :OrthLocation = getMyCurrentLocation();
        var walkability :Walkability = getScene().getDecor().getWalkability();

        if (walkability == null || myLoc == null) {
            return true;
        }

//        var from :Point = _layout.metrics.roomToScreen(myLoc.x, myLoc.y, myLoc.z);
//        from = _bg.viz.globalToLocal(from);
//
//        var to :Point = _layout.metrics.roomToScreen(toLoc.x, toLoc.y, toLoc.z);
//        to = _bg.viz.globalToLocal(to);
//
//        return walkability.isPathWalkable(from, to);
        return false;
    }

    /**
     * Updates the layout object, creating a new one if necessary.
     */
    protected function updateLayout (decor :Decor) :void
    {
        if (! (RoomLayoutFactory.isDecorSupported(_layout, decor))) {
            _layout = RoomLayoutFactory.createLayout(decor, this);
        }

        _layout.update(decor);
    }

    /**
     * Updates background and furniture sprites from their data objects.
     */
    public function updateAllFurni () :void
    {
        if (shouldLoadAll()) {
            for each (var furni :FurniData in _scene.getFurni()) {
                if (!MediaMimeTypes.isAudio(furni.media.getMimeType())) {
                    updateFurni(furni);
                }
            }
        }
    }

    public function getEntity (ident :EntityIdent) :EntitySprite
    {
        return _entities.get(ident) as EntitySprite;
    }

    /**
     * Execute the specified function for each entity.
     * function (key :EntityIdent, entity :EntitySprite) :void
     */
    public function forEachEntity (foreach :Function) :void
    {
        _entities.forEach(foreach);
    }

    public function getEntityIdents () :Array
    {
        return _entities.keys();
    }

    /*public function getEntityIdents (type :String) :Array
    {
        var keys :Array = _entities.keys();

        if (type != null) {
            var valid :Array = ENTITY_TYPES[type];
            keys = keys.filter(
        }

        return keys;
    }*/

    /**
     * Called when a sprite message arrives on the room object.
     */
    public function dispatchSpriteMessage (
        item :EntityIdent, name :String, arg :ByteArray, isAction :Boolean) :void
    {
        var sprite :EntitySprite = (_entities.get(item) as EntitySprite);
        if (sprite != null) {
            sprite.messageReceived(name, ObjectMarshaller.decode(arg), isAction);
        } else {
            log.info("Received sprite message for unknown sprite", "item", item, "name", name);
        }
    }

    /**
     * Called when a sprite signal arrives on the room object; iterates over the
     * entities present and notify them.
     */
    public function dispatchSpriteSignal (name :String, data :ByteArray) :void
    {
        // TODO: We are decoding the data for each sprite, because we can't trust
        // the usercode to not destructively modify the value in its event handler.
        // In the future, it might be good to rework this so that the value is not decoded
        // until the event handler actually requests the value using a getter(), but I
        // suspect that will require an increment to the version number in the function we
        // call... I don't want to do that just now.
        _entities.forEach(function (key :Object, sprite :EntitySprite) :void {
            sprite.signalReceived(name, ObjectMarshaller.decode(data));
        });
    }

    /**
     * Called when a memory entry is added or updated in the room object.
     */
    public function dispatchMemoryChanged (ident :EntityIdent, key :String, data :ByteArray) :void
    {
        var sprite :EntitySprite = (_entities.get(ident) as EntitySprite);
        if (sprite != null) {
            sprite.memoryChanged(key, ObjectMarshaller.decode(data));
        }
        // it's ok and normal for the sprite to not be here yet when the memory arrives
    }

    public function dispatchEntityEntered (item :EntityIdent) :void
    {
        if (item == null) {
            return;
        }
        var entityId :String = item.toString();
        _entities.forEach(function (mapKey :Object, sprite :EntitySprite) :void {
            sprite.entityEntered(entityId);
        });
    }

    public function dispatchEntityLeft (item :EntityIdent) :void
    {
        if (item == null) {
            return;
        }
        var entityId :String = item.toString();
        _entities.forEach(function (mapKey :Object, sprite :EntitySprite) :void {
            sprite.entityLeft(entityId);
        });
    }

    public function dispatchEntityMoved (item :EntityIdent, destination :Array) :void
    {
        var entityId :String = item.toString();
        _entities.forEach(function (mapKey :Object, sprite :EntitySprite) :void {
            sprite.entityMoved(entityId, destination);
        });
    }

    /**
     * Get the current music's metadata, suitable for dispatching to entities.
     */
    public function getMusicId3 () :Object
    {
        return null; // see subclasses
    }

    /**
     * Get the current music's ownerId, or 0.
     */
    public function getMusicOwner () :int
    {
        return 0; // see subclasses
    }

    /**
     * Populate the context menu for a sprite.
     */
    protected function populateSpriteContextMenu (sprite :EntitySprite, menuItems :Array) :void
    {
    }

    /**
     * Once the background image is finished, we want to load all the rest of the sprites.
     */
    protected function backgroundFinishedLoading () :void
    {
        _loadAllMedia = true;
        updateAllFurni();
        addAllOccupants();
    }

    protected function handlePrefsUpdated (event :NamedValueEvent) :void
    {
        switch (event.name) {
        case Prefs.APRIL_FOOLS:
            relayout();
            break;
        }
    }

    /**
     * Layout everything.
     */
    internal function relayout () :void
    {
        relayoutSprites(_furni.values());
        relayoutSprites(_otherSprites);
        relayoutSprites(_occupants.values());
        relayoutSprites(_pendingRemovals.values());
    }

    /**
     * Called from relayout(), relayout the specified sprites.
     */
    protected function relayoutSprites (sprites :Array) :void
    {
        for each (var sprite :EntitySprite in sprites) {
            relayoutSprite(sprite);
        }
    }

    /**
     * Do anything necessary to (re)layout a sprite.
     */
    protected function relayoutSprite (sprite :EntitySprite) :void
    {
        locationUpdated(sprite);
        sprite.roomScaleUpdated();
    }

    /**
     * Called when we detect a body being added or removed.
     */
    protected function portalTraversed (loc :Location, entering :Boolean) :void
    {
        var itr :Iterator = _scene.getPortals();
        while (itr.hasNext()) {
            var portal :Portal = (itr.next() as Portal);
            if (loc.equals(portal.loc)) {
                var sprite :FurniSprite = (_furni.get(portal.portalId) as FurniSprite);
                if (sprite != null) {
                    sprite.wasTraversed(entering);
                }
                return;
            }
        }
    }

    /**
     * Should we load everything that we know how to?  This is used by a subclass to restrict
     * loading to certain things when the room is first entered.
     */
    protected function shouldLoadAll () :Boolean
    {
        return _loadAllMedia;
    }

    /**
     * Effect the "global hover" on just one piece of furni.
     */
    protected function doGlobalHover (sprite :FurniSprite, on :Boolean) :void
    {
        if (!on || (sprite.isActive() && sprite.capturesMouse() && sprite.hasAction())) {
            _ctrl.setSpriteHovered(sprite, on);
        }
    }

    /**
     * Sets all sprites in the supplied map to active or non-active.
     */
    protected function setActive (map :Map, active :Boolean) :void
    {
        for each (var sprite :EntitySprite in map.values()) {
            sprite.setActive(active);
        }
    }

    /**
     * Shutdown all the sprites in the specified map.
     */
    protected function removeAll (map :Map) :void
    {
        for each (var sprite :EntitySprite in map.values()) {
            removeSprite(sprite);
        }
        map.clear();
    }

    protected function addFurni (furni :FurniData) :FurniSprite
    {
        var sprite :FurniSprite = _mediaDir.getFurni(furni);
        addSprite(sprite);
        sprite.setLocation(furni.loc);
        sprite.roomScaleUpdated();
        sprite.setEditing(_editing);
        _furni.put(furni.id, sprite);
        return sprite;
    }

    protected function updateFurni (furni :FurniData) :void
    {
        var sprite :FurniSprite = (_furni.get(furni.id) as FurniSprite);
        if (sprite != null) {
            dispatchEntityLeft(sprite.getEntityIdent());

            spriteWillUpdate(sprite);
            sprite.update(furni);
            spriteDidUpdate(sprite);
            locationUpdated(sprite);

            dispatchEntityEntered(sprite.getEntityIdent());
        } else {
            addFurni(furni);
        }
    }

    protected function removeFurni (furni :FurniData) :void
    {
        var sprite :FurniSprite = (_furni.remove(furni.id) as FurniSprite);
        if (sprite != null) {
            removeSprite(sprite);
        }
    }

    protected function addAllOccupants () :void
    {
        // see subclasses
    }

    protected function removeAllOccupants () :void
    {
        removeAll(_occupants);
        removeAll(_pendingRemovals);
    }

    /**
     * Add the specified sprite to the view.
     */
    protected function addSprite (sprite :EntitySprite) :void
    {
        var index :int = 0;
        addChildAt(sprite.viz, index);
        addToEntityMap(sprite);
    }

    /**
     * Remove the specified sprite from the view.
     */
    protected function removeSprite (sprite :EntitySprite) :void
    {
        if (sprite.viz.parent != this) {
            // TODO: I believe this happens when you leave a room and your greeter enters;
            // TODO: the sprite with bodyOid=0 ends up in _pendingRemovals and _occupants
            // TODO: both. I don't have time to track down precisely why this happens, but
            // TODO: let's stop throwing exceptions halfway through this code.
            log.warning("Trying to remove a sprite that's not our child", "sprite", sprite,
                        "parent", sprite.viz.parent);
            return;
        }

        _ctrl.setSpriteHovered(sprite, false);
        removeFromEntityMap(sprite);
        removeChild(sprite.viz);
        _mediaDir.returnSprite(sprite);
    }

    /**
     * Should be called prior to a sprite updating.
     */
    protected function spriteWillUpdate (sprite :EntitySprite) :void
    {
        removeFromEntityMap(sprite);
    }

    /**
     * Should be called after updating a sprite.
     */
    protected function spriteDidUpdate (sprite :EntitySprite) :void
    {
        addToEntityMap(sprite);
    }

    /**
     * Add the specified sprite to our entity map, if applicable.
     */
    protected function addToEntityMap (sprite :EntitySprite) :void
    {
        var ident :EntityIdent = sprite.getEntityIdent();
        if (ident != null) {
            _entities.put(ident, sprite);
        }
        addToElementMap(sprite);
    }

    /**
     * Remove the specified sprite to our entity map, if applicable.
     */
    protected function removeFromEntityMap (sprite :EntitySprite) :void
    {
        _entities.remove(sprite.getEntityIdent()); // could be a no-op
    }

    /**
     * Maps a {@link RoomElement}'s visualization (DisplayObject) back to the element.
     */
    protected function addToElementMap (element :RoomElement) :void
    {
        _elements.put(element.getVisualization(), element);
    }

    /**
     * Unmaps a {@link RoomElement}'s visualization.
     */
    protected function removeFromElementMap (element :RoomElement) :void
    {
        _elements.remove(element.getVisualization());
    }


    /** Our controller. */
    protected var _ctrl :RoomController;

    protected const _topPanel :TopPanel = inject(TopPanel);
    protected const _mediaDir :MediaDirector = inject(MediaDirector);
    protected const _sceneDir :OrthSceneDirector = inject(OrthSceneDirector);

    /** When we first enter the room, we only load the background (if any). */
    protected var _loadAllMedia :Boolean = false;

    /** A map of bodyOid -> OccupantSprite. */
    protected var _occupants :Map = Maps.newMapOf(int);

    /** Maps EntityIdent -> EntitySprite for entities (furni, avatars, pets). */
    protected var _entities :Map = Maps.newMapOf(EntityIdent);

    /** Maps DisplayObject -> RoomElement */
    protected var _elements :Map = Maps.newMapOf(DisplayObject);

    /** A map of bodyOid -> OccupantSprite for those that we'll remove when they stop moving. */
    protected var _pendingRemovals :Map = Maps.newMapOf(int);

    /** The msoy context. */
    protected var _ctx :RoomContext;

    /** The model of the current scene. */
    protected var _scene :OrthScene;

    /** What is the current offset into the RoomView that the player is watching? */
    protected var _scrollOffset :Point = new Point(0, 0);

    /** Object responsible for our spatial layout. */
    protected var _layout :RoomLayout;

    /** Helper object that draws a room backdrop with four walls. */
    protected var _backdrop :RoomBackdrop = new RoomBackdrop();

    /** A map of id -> Furni. */
    protected var _furni :Map = Maps.newMapOf(int);

    /** A list of other sprites (used during editing). */
    protected var _otherSprites :Array = new Array();

    /** Are we editing the scene? */
    protected var _editing :Boolean = false;
}
}


import com.threerings.orth.room.client.RoomElementSprite;

class BackdropOverlay extends RoomElementSprite
{
    public function BackdropOverlay ()
    {
        mouseEnabled = false;
    }

    override public function setScreenLocation (x :Number, y :Number, scale :Number) :void
    {
        // no op - this object cannot be moved, it's always displayed directly on top of the room
    }
}
