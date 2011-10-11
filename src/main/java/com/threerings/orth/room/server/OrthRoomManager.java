//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.room.server;

import java.util.Collection;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.Set;

import com.google.common.collect.Lists;
import com.google.common.collect.Maps;
import com.google.inject.Inject;

import com.samskivert.util.ObjectUtil;

import com.samskivert.jdbc.RepositoryUnit;

import com.threerings.presents.client.InvocationService.InvocationListener;
import com.threerings.presents.client.InvocationService;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.dobj.EntryAddedEvent;
import com.threerings.presents.dobj.EntryRemovedEvent;
import com.threerings.presents.dobj.EntryUpdatedEvent;
import com.threerings.presents.dobj.MessageEvent;
import com.threerings.presents.dobj.SetListener;
import com.threerings.presents.peer.server.PeerManager;
import com.threerings.presents.server.InvocationException;

import com.threerings.crowd.data.BodyObject;
import com.threerings.crowd.data.OccupantInfo;
import com.threerings.crowd.data.Place;
import com.threerings.crowd.data.PlaceObject;

import com.threerings.whirled.data.SceneUpdate;
import com.threerings.whirled.spot.data.Location;
import com.threerings.whirled.spot.data.Portal;
import com.threerings.whirled.spot.data.SceneLocation;
import com.threerings.whirled.spot.server.SpotSceneManager;

import com.threerings.orth.chat.data.OrthChatCodes;
import com.threerings.orth.chat.data.Speak;
import com.threerings.orth.chat.data.SpeakMarshaller;
import com.threerings.orth.chat.server.ChatManager;
import com.threerings.orth.chat.server.SpeakProvider;
import com.threerings.orth.data.PlayerName;
import com.threerings.orth.instance.server.InstancedSceneManager;
import com.threerings.orth.room.client.OrthRoomService;
import com.threerings.orth.room.data.ActorInfo;
import com.threerings.orth.room.data.ActorObject;
import com.threerings.orth.room.data.EntityIdent;
import com.threerings.orth.room.data.EntityMemories;
import com.threerings.orth.room.data.OrthLocation;
import com.threerings.orth.room.data.OrthRoomCodes;
import com.threerings.orth.room.data.OrthRoomMarshaller;
import com.threerings.orth.room.data.OrthRoomObject;
import com.threerings.orth.room.data.OrthScene;
import com.threerings.orth.room.data.RoomPlace;
import com.threerings.orth.room.data.SocializerObject;

import static com.threerings.orth.Log.log;

/**
 * Manages all the various complex operations of an actual instantiated Orth room.
 * This class relies on {@link MemoryRepository} having been previously bound.
 */
public class OrthRoomManager extends InstancedSceneManager
    implements OrthRoomProvider, SpeakProvider
{
    @Override
    public void sendSpriteMessage (ClientObject caller, EntityIdent item,
        String name, byte[] arg, boolean isAction)
    {
        // make sure the caller is in the room
        if (caller instanceof BodyObject) {
            BodyObject who = (BodyObject)caller;
            if (!_plobj.occupants.contains(who.getOid())) {
                return;
            }
        }

        // dispatch this as a simple MessageEvent
        _plobj.postMessage(OrthRoomCodes.SPRITE_MESSAGE, item, name, arg, isAction);
    }

    @Override
    public void speak (ClientObject caller, String msg, InvocationListener arg2)
        throws InvocationException
    {
        PlayerName name = ((SocializerObject)caller).name;

        Speak speak = new Speak(name, msg);
        if (_chatMan.check(speak)) {
            _plobj.postMessage(OrthChatCodes.SPEAK_MSG_TYPE, speak);
        }
    }

    @Override
    public void sendSpriteSignal (ClientObject caller, String name, byte[] arg)
    {
        // Caller could be a WindowClientObject if coming from a thane client
        if (caller instanceof BodyObject) {
            // make sure the caller is in the room
            BodyObject who = (BodyObject)caller;
            if (!_plobj.occupants.contains(who.getOid())) {
                return;
            }
        }

        // dispatch this as a simple MessageEvent
        _plobj.postMessage(OrthRoomCodes.SPRITE_SIGNAL, name, arg);
    }

    @Override
    public void setActorState (ClientObject caller, EntityIdent item, int actorOid, String state)
    {
        if (caller instanceof BodyObject) {
            BodyObject who = (BodyObject) caller;
            if (!_plobj.occupants.contains(who.getOid())) {
                return;
            }
        }

        // make sure the actor to be state-changed is also in this room
        ActorObject actor;
        if (caller.getOid() != actorOid) {
            if (!_plobj.occupants.contains(actorOid)) {
                return;
            }
            actor = (ActorObject) _omgr.getObject(actorOid);

        } else {
            // the actor is the caller
            actor = (ActorObject)caller;
        }

        // call the public (non-invocation service) method to enact it
        setState(actor, state);
    }

    @Override
    public void editRoom (ClientObject caller, InvocationService.ResultListener listener)
        throws InvocationException
    {
        // for now send back a TRUE
        listener.requestProcessed(Boolean.TRUE);
    }

    // documentation inherited from RoomProvider
    public void updateRoom (ClientObject caller, final SceneUpdate update,
                            InvocationService.InvocationListener listener)
        throws InvocationException
    {
        throw new IllegalStateException("Not yet implemented");
    }


    @Override
    public void updateMemory (ClientObject caller, EntityIdent ident,
        String key, byte[] newValue, OrthRoomService.ResultListener listener)
    {
        // do any first-level validation based on the item and the caller
        if (!validateMemoryUpdate((ActorObject)caller, ident)) {
            listener.requestProcessed(Boolean.FALSE);
            return;
        }

        // verify that the memory does not exceed legal size
        EntityMemories mems = _orthObj.memories.get(ident);
        int totalSize = (mems == null) ? 0 : mems.getSize(key);
        int newSize = EntityMemories.getSize(key, newValue);
        if ((totalSize + newSize) > EntityMemories.MAX_ENCODED_MEMORY_LENGTH) {
            log.info("Rejecting memory update as too large",
                "otherSize", totalSize, "newEntrySize", newSize);
            // Let the client know we looked at the memory, but didn't actually store it
            listener.requestProcessed(Boolean.FALSE);
            return;
        }

        // mark it as modified and update the room object; we'll save it when we unload the room
        _orthObj.updateMemory(ident, key, newValue);
        listener.requestProcessed(Boolean.TRUE);
    }

    @Override
    public void changeLocation (ClientObject caller, EntityIdent item, Location newLoc)
    {
        int oid = findActorOid(item);
        if (oid != 0) {
            _orthObj.updateOccupantLocs(new SceneLocation(newLoc, oid));
        }
    }

    /**
     * Forcibly change the state of an actor.
     */
    public void setState (ActorObject actor, String state)
    {
        // update the state in their body object
        actor.actorState = state;
        // and in the occInfo
        setState(actor.getOid(), state);
    }

    /**
     * Part 2 of setting an actor's state. Also used if the actor has no body.
     */
    public void setState (int occupantOid, final String state)
    {
        // TODO: consider, instead of updating the whole dang occInfo, dispatching a custom event
        // that will update just the state and serve as the trigger event to usercode...
        updateOccupantInfo(occupantOid, new ActorInfo.Updater<ActorInfo>() {
            public boolean update (ActorInfo info) {
                if (ObjectUtil.equals(info.getState(), state)) {
                    return false; // if there was no change, we're done.
                }
                info.setState(state);
                return true;
            }
        });
    }

    @Override // from PlaceManager
    public void bodyWillEnter (BodyObject body)
    {
        if (body instanceof ActorObject) {
            ActorObject actor = (ActorObject) body;

            if (actor.getEntityIdent() != null) {
                // as we arrive at a room, we entrust it with our memories for broadcast to clients
                body.getLocal(ActorLocal.class).willEnterRoom(actor, _orthObj);
            }
        }

        // Note: we want to add the occupant info *after* we set up the party
        // (in MemberLocal.willEnterRoom), so we call super last.
        super.bodyWillEnter(body);
    }

    @Override // from PlaceManager
    public void bodyWillLeave (BodyObject body)
    {
        // super first. See "Note", below.
        super.bodyWillLeave(body);

        // Note: Calling MemberLocal.willLeaveRoom() must now occur after we've removed the
        // OccupantInfo, which happens in super.
        if (body instanceof ActorObject) {
            ActorObject actor = (ActorObject)body;
            ActorLocal local = actor.getLocal(ActorLocal.class);
            local.willLeaveRoom(actor, _orthObj);

            // clone the outgoing owner's memories
            EntityMemories mems = local.memories;
            if (mems != null) {
                mems = mems.clone();
                mems.modified = false; // clear the modified flag in the clone...
            }
        }
    }

    @Override // from SpotSceneManager
    public void willTraversePortal (BodyObject body, Portal portal)
    {
        OrthLocation loc = (OrthLocation) portal.getLocation();
        // We need to set the body's orientation to match the approach to the portal.
        // Look up their current location and move them from there. This could be a little
        // "off" if their sprite has not yet walked to this location, but oh well.
        SceneLocation sloc = _orthObj.occupantLocs.get(body.getOid());
        if (sloc != null) {
            OrthLocation origin = (OrthLocation) sloc.loc;
            double radians = Math.atan2(loc.z - origin.z, loc.x - origin.x);
            // turn the radians into a positive degree value in the whirled orientation space
            loc.orient = (short) ((360 + 90 + (int) Math.round(Math.toDegrees(radians))) % 360);
        }

        // note: we don't call super, we call updateLocation() ourselves
        updateLocation(body, loc);
    }

    @Override // from PlaceManager
    public void messageReceived (MessageEvent event)
    {
        // we want to explicitly disable the standard method calling by name that we allow in more
        // trusted environments
    }

    @Override
    public Place getLocation ()
    {
        return new RoomPlace(_peerMgr.getNodeObject().nodeName, _plobj.getOid(),
            _scene.getId(), _orthObj.name);
    }

    @Override // from PlaceManager
    protected PlaceObject createPlaceObject ()
    {
        return new OrthRoomObject();
    }

    @Override // from SceneManager
    protected void gotSceneData (Object extras)
    {
        super.gotSceneData(extras);

        _extras = (OrthRoomExtras) extras;
    }

    @Override // from PlaceManager
    protected void didStartup ()
    {
        super.didStartup();

        // set up our room object
        _orthObj = (OrthRoomObject) _plobj;
        _orthObj.setOrthRoomService(addProvider(this, OrthRoomMarshaller.class));
        _orthObj.addListener(_roomListener);


        // add the Orth speak service for this room
        _orthObj.orthSpeakService = addProvider(this, SpeakMarshaller.class);

        OrthScene mscene = (OrthScene) _scene;
        _orthObj.startTransaction();
        try {
            // if we have memories for the items in our room, add'em to the room object
            _orthObj.setName(mscene.getName());
            if (_extras.memories != null) {
                addMemoriesToRoom(_extras.memories);
            }

        } finally {
            _orthObj.commitTransaction();
        }

        // we're done with our auxiliary scene information, let's let it garbage collect
        _extras = null;
    }

    @Override // from PlaceManager
    protected void didShutdown ()
    {
        _orthObj.removeListener(_roomListener);

        super.didShutdown();

        // flush any modified memory records to the database
        _memSupply.flushMemories(_orthObj.memories.asSet());
    }

    /** A trivial class that remembers nothing. */
    public static class AmnesiacMemorySupply implements MemoryRepository
    {
        @Override public List<EntityMemories> loadMemories (Set<EntityIdent> memoryIds) {
            // we remember nothing from before
            return Lists.newArrayList();
        }
        @Override public void flushMemories (Iterable<EntityMemories> memories) {
            // forget what we've learned
        }
    }

    /**
     * Loads up the specified memories and places them into the room object.
     */
    protected void resolveMemories (final EntityIdent ident, final Runnable onCompletion)
    {
        _invoker.postUnit(new RepositoryUnit("resolveMemories") {
            @Override public void invokePersist () throws Exception {
                _result = _memSupply.loadMemories(Collections.singleton(ident));
            }
            @Override public void handleSuccess () {
                addMemoriesToRoom(_result);
                if (onCompletion != null) {
                    onCompletion.run();
                }
            }
            @Override public void handleFailure (Exception e) {
                log.warning("Failed to resolve memories for entity", "ident", ident, e);
                if (onCompletion != null) {
                    onCompletion.run();
                }
            }
            protected List<EntityMemories> _result;
        });
    }

    protected void addMemoriesToRoom (Collection<EntityMemories> memories)
    {
        _orthObj.startTransaction();
        try {
            for (EntityMemories mem : memories) {
                _orthObj.putMemories(mem);
            }
        } finally {
            _orthObj.commitTransaction();
        }
    }


    /**
     * Validate that the caller be allowed to update memory for the item.
     */
    protected boolean validateMemoryUpdate (ActorObject caller, EntityIdent ident)
    {
        return true;
    }

    protected void removeAndFlushMemories (EntityIdent entityIdent)
    {
        EntityMemories removed = _orthObj.takeMemories(entityIdent);
        if (removed != null) {
            // persist any of the old memories that were modified
            _memSupply.flushMemories(Collections.singleton(removed));
        }
    }

    /**
     * Determine the actor oid that corresponds to the specified ItemIdent, or return 0 if none
     * found.
     */
    protected int findActorOid (EntityIdent item)
    {
        // see if it's an avatar
        Integer oid = _avatarIdents.get(item);
        if (oid != null) {
            return oid.intValue();
        }

        // otherwise, scan all occupant infos. Perhaps we should keep a mapping for non-avatar
        // actors as well?
        for (OccupantInfo info : _plobj.occupantInfo) {
            if (info instanceof ActorInfo) {
                ActorInfo ainfo = (ActorInfo)info;
                if (ainfo.getEntityIdent().equals(item)) {
                    return ainfo.getBodyOid();
                }
            }
        }

        return 0; // never found it..
    }

    /** Listens to the room. */
    protected class RoomListener
        implements SetListener<OccupantInfo>
    {
        // from SetListener
        public void entryAdded (EntryAddedEvent<OccupantInfo> event)
        {
            String name = event.getName();
            if (name == PlaceObject.OCCUPANT_INFO) {
                updateAvatarIdent(null, event.getEntry());
            }
        }

        // from SetListener
        public void entryUpdated (EntryUpdatedEvent<OccupantInfo> event)
        {
            String name = event.getName();
            if (name == PlaceObject.OCCUPANT_INFO) {
                if (event.getEntry() instanceof ActorInfo) {
                    ActorInfo entry = (ActorInfo)event.getEntry();
                    ActorInfo oldEntry = (ActorInfo)event.getOldEntry();

                    // see if they actually switched avatars
                    if (!entry.getEntityIdent().equals(oldEntry.getEntityIdent())) {
                        updateAvatarIdent(oldEntry, entry);
                        removeAndFlushMemories(oldEntry.getEntityIdent());
                    }
                }
            }
        }

        // from SetListener
        public void entryRemoved (EntryRemovedEvent<OccupantInfo> event)
        {
            String name = event.getName();
            if (name == PlaceObject.OCCUPANT_INFO) {
                updateAvatarIdent(event.getOldEntry(), null);
            }
        }

        /**
         * Maintain a mapping of ItemIdent -> oid for all MemberInfos.
         */
        protected void updateAvatarIdent (OccupantInfo oldInfo, OccupantInfo newInfo)
        {
            // we only track MemberInfo, as those are the only things that represent MemberObjects
            if (oldInfo instanceof ActorInfo) {
                _avatarIdents.remove(((ActorInfo)oldInfo).getEntityIdent());
            }
            if (newInfo instanceof ActorInfo) {
                _avatarIdents.put(((ActorInfo)newInfo).getEntityIdent(), newInfo.bodyOid);
            }
        }
    }

    /** The room object. */
    protected OrthRoomObject _orthObj;

    /** Extra data from scene resolution. */
    protected OrthRoomExtras _extras;

    /** For all MemberInfo's, a mapping of ItemIdent to the member's oid. */
    protected Map<EntityIdent, Integer> _avatarIdents = Maps.newHashMap();

    /** Listens to the room object. */
    protected RoomListener _roomListener = new RoomListener();

    @Inject protected ChatManager _chatMan;
    @Inject protected MemoryRepository _memSupply;
    @Inject protected PeerManager _peerMgr;
}
