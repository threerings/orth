//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.room.client {
import com.threerings.orth.room.data.FurniData;
import com.threerings.util.Sets;

import flash.geom.Point;
import flash.utils.ByteArray;

import com.threerings.crowd.chat.client.ChatDisplay;
import com.threerings.crowd.chat.client.ChatSnooper;
import com.threerings.crowd.chat.data.ChatMessage;
import com.threerings.crowd.data.OccupantInfo;
import com.threerings.crowd.data.PlaceObject;
import com.threerings.whirled.data.SceneUpdate;
import com.threerings.whirled.spot.data.SceneLocation;
import com.threerings.whirled.spot.data.SpotSceneObject;

import com.threerings.util.Map;
import com.threerings.util.Name;
import com.threerings.util.ObserverList;
import com.threerings.util.Predicates;
import com.threerings.util.Set;

import com.threerings.presents.dobj.EntryAddedEvent;
import com.threerings.presents.dobj.EntryRemovedEvent;
import com.threerings.presents.dobj.EntryUpdatedEvent;
import com.threerings.presents.dobj.MessageEvent;
import com.threerings.presents.dobj.MessageListener;
import com.threerings.presents.dobj.SetListener;

import com.threerings.orth.chat.client.SpeakerObserver;
import com.threerings.orth.client.LoadingWatcher;
import com.threerings.orth.entity.client.EntitySprite;
import com.threerings.orth.entity.client.FurniSprite;
import com.threerings.orth.entity.client.MemberSprite;
import com.threerings.orth.entity.client.OccupantSprite;
import com.threerings.orth.entity.client.PetSprite;
import com.threerings.orth.room.data.EntityIdent;
import com.threerings.orth.room.data.EntityMemories;
import com.threerings.orth.room.data.FurniUpdate_Remove;
import com.threerings.orth.room.data.MemoryChangedListener;
import com.threerings.orth.room.data.OrthLocation;
import com.threerings.orth.room.data.OrthRoomCodes;
import com.threerings.orth.room.data.OrthRoomObject;
import com.threerings.orth.room.data.OrthScene;
import com.threerings.orth.room.data.SceneAttrsUpdate;

/**
 * Extends the base roomview with the ability to view a RoomObject, view chat, and edit.
 */
public class RoomObjectView extends RoomView
    implements SetListener, MessageListener, ChatSnooper, ChatDisplay,
               MemoryChangedListener, SpeakerObserver
{
    /**
     * Create a roomview.
     */
    public function RoomObjectView (ctx :RoomContext, ctrl :RoomObjectController)
    {
        super(ctx, ctrl);
        _octrl = ctrl;
    }

    public function getRoomObjectController () :RoomObjectController
    {
        return _octrl;
    }

    /**
     * Have we finished loading all the furni/decor in this room?
     * Note that adding new furniture to the room may cause this to return false.
     */
    public function loadingDone () :Boolean
    {
        return (_loadingWatcher != null) && _loadingWatcher.isFinished();
    }

    /**
     * (Re)set our scene to the one the scene director knows about.
     */
    public function rereadScene () :void
    {
        setScene(_sceneDir.getScene() as OrthScene);
    }

    /**
     * Called by the editor to have direct access to our sprite list..
     */
    public function getFurniSprites () :Map
    {
        return _furni;
    }

    /**
     * Enable or disable editing.
     */
    public function setEditing (editing :Boolean) :void
    {
        _editing = editing;

        // update all sprites
        _furni.forEach(function (key :*, sprite :EntitySprite) :void {
            sprite.setEditing(_editing);
        });

        if (!_editing) {
            // definitely update the furni
            updateAllFurni();
        }

        // if we haven't yet started loading sprites other than the background, start now
        if (!_loadAllMedia) {
            _loadAllMedia = true;
            updateAllFurni();
        }
    }

    /**
     * Called by our controller when a scene update is received.
     */
    public function processUpdate (update :SceneUpdate) :void
    {
        if (update is FurniUpdate_Remove) {
            removeFurni((update as FurniUpdate_Remove).data);

        } else if (update is SceneAttrsUpdate) {
            rereadScene(); // re-read our scene
        }

        // this will take care of anything added
        updateAllFurni();
    }

    /**
     * A convenience function to get our personal avatar.
     */
    override public function getMyAvatar () :MemberSprite
    {
        return (getOccupant(_ctx.getClient().getClientOid()) as MemberSprite);
    }

    /**
     * A convenience function to get the specified occupant sprite, even if it's on the way out the
     * door.
     */
    public function getOccupant (bodyOid :int) :OccupantSprite
    {
        var sprite :OccupantSprite = (_occupants.get(bodyOid) as OccupantSprite);
        if (sprite == null) {
            sprite = (_pendingRemovals.get(bodyOid) as OccupantSprite);
        }
        return sprite;
    }

    /**
     * A convenience function to get the specified occupant sprite, even if it's on the way out the
     * door.
     */
    public function getOccupantByName (name :Name) :OccupantSprite
    {
        if (_roomObj == null) {
            return null;
        }

        var occInfo :OccupantInfo = _roomObj.getOccupantInfo(name);
        return (occInfo == null) ? null : getOccupant(occInfo.bodyOid);
    }

    /**
     * A convenience function to get an array of all sprites for all pets in the room.
     */
    public function getPets () :Array /* of PetSprite */
    {
        return _occupants.values().filter(Predicates.createIs(PetSprite));
    }

    // from interface SetListener
    public function entryAdded (event :EntryAddedEvent) :void
    {
        var name :String = event.getName();

        if (PlaceObject.OCCUPANT_INFO == name) {
            addBody(event.getEntry() as OccupantInfo);

        } else if (SpotSceneObject.OCCUPANT_LOCS == name) {
            var sceneLoc :SceneLocation = (event.getEntry() as SceneLocation);
            portalTraversed(sceneLoc.loc, true);

        } else if (OrthRoomObject.MEMORIES == name) {
            var entry :EntityMemories = event.getEntry() as EntityMemories;
            entry.memories.forEach(function (key :String, value :ByteArray) :void {
                dispatchMemoryChanged(entry.ident, key, value);
            });
        }
    }

    // from interface SetListener
    public function entryUpdated (event :EntryUpdatedEvent) :void
    {
        var name :String = event.getName();

        if (PlaceObject.OCCUPANT_INFO == name) {
            updateBody(event.getEntry() as OccupantInfo, event.getOldEntry() as OccupantInfo);

        } else if (SpotSceneObject.OCCUPANT_LOCS == name) {
            moveBody((event.getEntry() as SceneLocation).bodyOid);

        } else if (OrthRoomObject.MEMORIES == name) {
            // TODO: this presently should not happen, but we cope and treat it like an add
            var entry :EntityMemories = event.getEntry() as EntityMemories;
            entry.memories.forEach(function (key :String, value :ByteArray) :void {
                dispatchMemoryChanged(entry.ident, key, value);
            });
        }
    }

    // from interface SetListener
    public function entryRemoved (event :EntryRemovedEvent) :void
    {
        var name :String = event.getName();

        if (PlaceObject.OCCUPANT_INFO == name) {
            removeBody((event.getOldEntry() as OccupantInfo).getBodyOid());
        }
    }

    // from interface MemoryChangedListener
    public function memoryChanged (ident :EntityIdent, key :String, value :ByteArray) :void
    {
        dispatchMemoryChanged(ident, key, value);
    }

    // from interface MessageListener
    public function messageReceived (event :MessageEvent) :void
    {
        var args :Array = event.getArgs();
        switch (event.getName()) {
        case OrthRoomCodes.SPRITE_MESSAGE:
            dispatchSpriteMessage((args[0] as EntityIdent), (args[1] as String),
                                  (args[2] as ByteArray), (args[3] as Boolean));
            break;
        case OrthRoomCodes.SPRITE_SIGNAL:
            dispatchSpriteSignal((args[0] as String), (args[1] as ByteArray));
            break;
        }
    }

    // from ChatInfoProvider
    override public function getBubblePosition (speaker :Name) :Point
    {
        var sprite :OccupantSprite = getOccupantByName(speaker);
        return (sprite == null) ? null : sprite.getBubblePosition();
    }

    // from ChatInfoProvider
    override public function addBubbleObserver (observer :SpeakerObserver) :void
    {
        _bubbleObservers.add(observer);
    }

    // from ChatInfoProvider
    override public function removeBubbleObserver (observer :SpeakerObserver) :void
    {
        _bubbleObservers.remove(observer);
    }

    // from OccupantChatOverlay
    public function speakerMoved (speaker :Name, pos :Point) :void
    {
        // some occupant has moved; relay to our observers
        _bubbleObservers.apply(function (obs :SpeakerObserver) :void {
           obs.speakerMoved(speaker, pos);
        });
    }

    // from ChatDisplay
    public function clear () :void
    {
        // nada
    }

    // from ChatDisplay
    public function displayMessage (msg :ChatMessage) :void
    {
        // we don't do this in snoopChat in case the message was filtered into nothing
        var avatar :MemberSprite = getSpeaker(msg) as MemberSprite;
        if (avatar != null) {
            avatar.performAvatarSpoke();
        }
    }

    // from ChatSnooper
    public function snoopChat (msg :ChatMessage) :void
    {
        var speaker :OccupantSprite = getSpeaker(msg);
        if (speaker != null) {
            // send it to all entities
            var ident :String = speaker.getEntityIdent().toString();
            var name :String = speaker.getOccupantInfo().username.toString();
            for each (var entity :EntitySprite in _entities.values()) {
                entity.processChatMessage(ident, name, msg.message);
            }
        }
    }

    // from RoomView
    override public function willEnterPlace (plobj :PlaceObject) :void
    {
        // set load-all to false, as we're going to just load the decor item first.
        _loadAllMedia = false;

        _loadingWatcher = getLoadingWatcher();
        FurniSprite.setLoadingWatcher(_loadingWatcher);

        // save our scene object
        _roomObj = (plobj as OrthRoomObject);

        rereadScene();
        updateAllFurni();

        _roomObj.addListener(this);

        addAllOccupants();

        // we add ourselves as a chat display so that we can trigger speak actions on avatars
        _ctx.getChatDirector().addChatSnooper(this);
        _ctx.getChatDirector().addChatDisplay(this);

        // and animate ourselves entering the room (everyone already in the (room will also have
        // seen it)
        portalTraversed(getMyCurrentLocation(), true);

        // hide until our furni sprites are loaded
        this.visible = false;

        // start loading them
        preloadFurni();
    }

    // from RoomView
    override public function didLeavePlace (plobj :PlaceObject) :void
    {
        _roomObj.removeListener(this);

        // stop listening for avatar speak action triggers
        _ctx.getChatDirector().removeChatDisplay(this);
        _ctx.getChatDirector().removeChatSnooper(this);

        removeAllOccupants();

        super.didLeavePlace(plobj);

        _roomObj = null;

        _loadingWatcher = null;
        FurniSprite.setLoadingWatcher(null);
    }

    /**
     * Return the sprite of the speaker of the specified message.
     */
    protected function getSpeaker (msg :ChatMessage) :OccupantSprite
    {
        // ORTH TODO: reintroduce
//        if (msg is UserMessage && OrthChatChannel.typeIsForRoom(msg.localtype, _scene.getId())) {
//            return getOccupantByName(UserMessage(msg).getSpeakerDisplayName());
//        }
        return null;
    }

    protected function preloadFurni () :void
    {
        _furniDatas = Sets.newSetOf(FurniData, _scene.getFurni());
        _scene.getFurni().forEach(function (data :FurniData, ix :int, arr :Array) :void {
            updateFurni(data);
            var sprite :FurniSprite = (_furni.get(data.id) as FurniSprite);
            if (sprite != null) {
                sprite.setLoadedCallback(furniSpritePreloaded);
            } else {
                // shouldn't really be happening...
                _furniDatas.remove(data);
            }
        });
    }

    protected function furniSpritePreloaded (sprite :FurniSprite) :void
    {
        _furniDatas.remove(sprite.getFurniData());
        if (_furniDatas.isEmpty()) {
            backgroundFinishedLoading();
        }
    }

    override protected function backgroundFinishedLoading () :void
    {
        this.visible = true;
        super.backgroundFinishedLoading();

        _octrl.backgroundFinishedLoading();
    }

    protected function getLoadingWatcher () :LoadingWatcher
    {
        // subclasses can return something more exciting here
        return null;
    }

    protected function addBody (occInfo :OccupantInfo) :void
    {
        if (!shouldLoadAll()) {
            return;
        }

        // TODO: handle viewonly occupants

        var bodyOid :int = occInfo.getBodyOid();
        var sloc :SceneLocation = (_roomObj.occupantLocs.get(bodyOid) as SceneLocation);
        var loc :OrthLocation = (sloc.loc as OrthLocation);

        // see if the occupant was already created, pending removal
        var occupant :OccupantSprite = (_pendingRemovals.remove(bodyOid) as OccupantSprite);

        if (occupant == null) {
            occupant = _mediaDir.getSprite(occInfo, _roomObj);
            if (occupant == null) {
                return; // we have no visualization for this kind of occupant, no problem
            }

            _occupants.put(bodyOid, occupant);
            addSprite(occupant);
            dispatchEntityEntered(occupant.getEntityIdent());
            occupant.setEntering(loc);
            occupant.roomScaleUpdated();

        } else {
            // update the sprite
            spriteWillUpdate(occupant);
            occupant.setOccupantInfo(occInfo, _roomObj);
            spriteDidUpdate(occupant);

            // place the sprite back into the set of active sprites
            _occupants.put(bodyOid, occupant);
            occupant.moveTo(loc, _scene);
        }
    }

    protected function removeBody (bodyOid :int) :void
    {
        var sprite :OccupantSprite = (_occupants.remove(bodyOid) as OccupantSprite);
        if (sprite == null) {
            return;
        }
        if (sprite.isMoving()) {
            _pendingRemovals.put(bodyOid, sprite);
        } else {
            dispatchEntityLeft(sprite.getEntityIdent());
            removeSprite(sprite);
        }
    }

    protected function moveBody (bodyOid :int) :void
    {
        var sprite :OccupantSprite = (_occupants.get(bodyOid) as OccupantSprite);
        if (sprite == null) {
            // It's possible to get an occupant update while we're still loading the room
            // and haven't yet set up the occupant's sprite. Ignore.
            return;
        }
        var sloc :SceneLocation = (_roomObj.occupantLocs.get(bodyOid) as SceneLocation);
        sprite.moveTo(sloc.loc as OrthLocation, _scene);
    }

    protected function updateBody (newInfo :OccupantInfo, oldInfo :OccupantInfo) :void
    {
        var sprite :OccupantSprite = (_occupants.get(newInfo.getBodyOid()) as OccupantSprite);
        if (sprite == null) {
            // It's possible to get an occupant update while we're still loading the room
            // and haven't yet set up the occupant's sprite. Ignore.
            return;
        }
        spriteWillUpdate(sprite);
        sprite.setOccupantInfo(newInfo, _roomObj);
        spriteDidUpdate(sprite);
    }

    override protected function addAllOccupants () :void
    {
        if (!shouldLoadAll()) {
            return;
        }

        // add all currently present occupants
        for each (var occInfo :OccupantInfo in _roomObj.occupantInfo.toArray()) {
            if (!_occupants.containsKey(occInfo.getBodyOid())) {
                addBody(occInfo);
            }
        }
    }

    /** _ctrl, casted as a RoomObjectController. */
    protected var _octrl :RoomObjectController;

    /** The transitory properties of the current scene. */
    protected var _roomObj :OrthRoomObject;

    /** The furni to load before we unveil ourselves. */
    protected var _furniDatas :Set;

    /** Monitors and displays loading progress for furni/decor. */
    protected var _loadingWatcher :LoadingWatcher;

    /** Objects that want to know when speakers move around. */
    protected var _bubbleObservers :ObserverList =
        new ObserverList(ObserverList.SAFE_IN_ORDER_NOTIFY);
}
}
