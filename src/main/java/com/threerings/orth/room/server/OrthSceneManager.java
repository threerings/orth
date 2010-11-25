package com.threerings.orth.room.server;

import java.util.Collection;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.TreeSet;

import com.google.common.collect.Lists;
import com.google.common.collect.Maps;
import com.google.inject.Inject;
import com.samskivert.util.Comparators;
import com.samskivert.util.ObjectUtil;
import com.samskivert.util.ResultListener;
import com.threerings.crowd.data.BodyObject;
import com.threerings.crowd.data.OccupantInfo;
import com.threerings.crowd.data.PlaceObject;
import com.threerings.orth.room.client.OrthRoomService;
import com.threerings.orth.room.data.ActorInfo;
import com.threerings.orth.room.data.EntityControl;
import com.threerings.orth.room.data.EntityIdent;
import com.threerings.orth.room.data.EntityMemories;
import com.threerings.orth.room.data.ActorObject;
import com.threerings.orth.room.data.OrthLocation;
import com.threerings.orth.room.data.OrthScene;
import com.threerings.orth.room.data.OrthSceneCodes;
import com.threerings.orth.room.data.OrthSceneObject;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.dobj.EntryAddedEvent;
import com.threerings.presents.dobj.EntryRemovedEvent;
import com.threerings.presents.dobj.EntryUpdatedEvent;
import com.threerings.presents.dobj.MessageEvent;
import com.threerings.presents.dobj.SetListener;
import com.threerings.whirled.spot.data.Location;
import com.threerings.whirled.spot.data.Portal;
import com.threerings.whirled.spot.data.SceneLocation;
import com.threerings.whirled.spot.server.SpotSceneManager;

import static com.threerings.orth.Log.log;

public abstract class OrthSceneManager extends SpotSceneManager
    implements OrthSceneProvider
{
    public OrthSceneManager ()
    {
        super();
    }

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

        // if this client does not currently control this entity; ignore the request; if no one
        // controls it, this will assign this client as controller
        if (isAction && !ensureEntityControl(caller, item, "triggerAction")) {
            log.info("Dropping sprite message for lack of control", "who", caller.who(),
                "item", item, "name", name);
            return;
        }

        // dispatch this as a simple MessageEvent
        _plobj.postMessage(OrthSceneCodes.SPRITE_MESSAGE, item, name, arg, isAction);
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
        _plobj.postMessage(OrthSceneCodes.SPRITE_SIGNAL, name, arg);
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

        // if this client does not currently control this entity; ignore the request; if no one
        // controls it, this will assign this client as controller
        if (!ensureEntityControl(caller, item, "setState")) {
            log.info("Dropping change state for lack of control", "who", caller.who(),
                "item", item, "state", state);
            return;
        }

        // call the public (non-invocation service) method to enact it
        setState(actor, state);
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
    public void requestControl (ClientObject caller, EntityIdent item)
    {
        ensureEntityControl(caller, item, "requestControl");
        // TODO: throw invocationexception on failure?
    }

    @Override
    public void changeLocation (ClientObject caller, EntityIdent item, Location newLoc)
    {
        // if this client does not currently control this entity; ignore the request; if no one
        // controls it, this will assign this client as controller
        if (!ensureEntityControl(caller, item, "changeLocation")) {
            return;
        }

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

    @Override // from PlaceManager
    protected PlaceObject createPlaceObject ()
    {
        return new OrthSceneObject();
    }

    @Override // from SceneManager
    protected void gotSceneData (Object extras)
    {
        super.gotSceneData(extras);

        _extras = (OrthSceneExtras) extras;
    }

    @Override // from PlaceManager
    protected void didStartup ()
    {
        super.didStartup();

        // set up our room object
        _orthObj = (OrthSceneObject) _plobj;
        _orthObj.setOrthSceneService(addDispatcher(new OrthSceneDispatcher(this)));
        _orthObj.addListener(_roomListener);

        OrthScene mscene = (OrthScene) _scene;
        _orthObj.startTransaction();
        try {
            // if we have memories for the items in our room, add'em to the room object
            _orthObj.setName(mscene.getName());
            _orthObj.setOwner(mscene.getOwner());
            _orthObj.setAccessControl(mscene.getAccessControl());
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
    protected void bodyUpdated (OccupantInfo info)
    {
        super.bodyUpdated(info);

        // if this occupant just disconnected, reassign their controlled entities
        if (info.status == OccupantInfo.DISCONNECTED) {
            reassignControllers(info.bodyOid);
        }
    }

    @Override // from PlaceManager
    protected void bodyLeft (int bodyOid)
    {
        super.bodyLeft(bodyOid);

        // reassign this occupant's controlled entities
        reassignControllers(bodyOid);
    }

    @Override // from PlaceManager
    protected void didShutdown ()
    {
        _orthObj.removeListener(_roomListener);

        super.didShutdown();

        // flush any modified memory records to the database
        _memSupply.flushMemories(_orthObj.memories.asSet());
    }

    public interface MemorySupply
    {
        void loadMemory (EntityIdent ident, ResultListener<EntityMemories> listener);
        void flushMemories (Iterable<EntityMemories> memories);
    }

    /**
     * Loads up the specified memories and places them into the room object.
     */
    protected void resolveMemories (final EntityIdent ident, final Runnable onCompletion)
    {
        _memSupply.loadMemory(ident, new ResultListener<EntityMemories>() {
            @Override public void requestCompleted (EntityMemories result) {
                addMemoriesToRoom(Collections.singleton(result));
                if (onCompletion != null) {
                    onCompletion.run();
                }
            }
            @Override public void requestFailed (Exception cause) {
                log.warning("Failed to resolve memories for entity", "ident", ident);
                if (onCompletion != null) {
                    onCompletion.run();
                }
            }
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
     * Checks to see if an item is being controlled by any client. If not, the calling client is
     * assigned as the item's controller and true is returned. If the item is already being
     * controlled or is controllable by the calling client, true is returned. Otherwise false is
     * returned (indicating that another client currently has control of the item or the client
     * is not allowed to control the item).
     */
    protected boolean ensureEntityControl (ClientObject who, EntityIdent item, String from)
    {
        EntityControl ctrl = _orthObj.controllers.get(item);
        if (ctrl == null) {
            //log.info("Assigning control", "item", item, "to", who.who());
            _orthObj.addToControllers(new EntityControl(item, who.getOid()));
            return true;
        }
        return (ctrl.controllerOid == who.getOid());
    }

    /**
     * Reassigns all scene entities controlled by the specified client to new controllers.
     */
    protected void reassignControllers (int bodyOid)
    {
        // determine which items were under the control of this user
        List<EntityIdent> items = Lists.newArrayList();
        for (EntityControl ctrl : _orthObj.controllers) {
            if (ctrl.controllerOid == bodyOid) {
                items.add(ctrl.entity);
            }
        }
        if (items.size() == 0) {
            return;
        }

        // clear out the old controller mappings
        _orthObj.startTransaction();
        try {
            for (EntityIdent item : items) {
                _orthObj.removeFromControllers(item);
            }
        } finally {
            _orthObj.commitTransaction();
        }

        // assign new mappings to remaining users
        assignControllers(items);
    }

    protected boolean isPotentialController (OccupantInfo info)
    {
        return info.status != OccupantInfo.DISCONNECTED;
    }

    /**
     * Handles a request to select a controller for the supplied set of items.
     */
    protected boolean assignControllers (Collection<EntityIdent> items)
    {
        // determine the available controllers
        Map<Integer, Controller> controllers = Maps.newHashMap();
        for (OccupantInfo info : _orthObj.occupantInfo) {
            if (isPotentialController(info)) {
                controllers.put(info.bodyOid, new Controller(info.bodyOid));
            }
        }

        // if we have no potential controllers, the controllables will remain uncontrolled (which
        // is much better than them being out of control :)
        if (controllers.size() == 0) {
            return false;
        }

        // note the current load of these controllers
        for (EntityControl ctrl : _orthObj.controllers) {
            Controller owner = controllers.get(ctrl.controllerOid);
            if (owner != null) {
                owner.load++;
            }
        }

        // choose the least loaded controller that is compatible with the controllable, remove the
        // controller from the set, assign them control of the controllable, add them back to the
        // set, then finally move to the next item
        try {
            _orthObj.startTransaction();
            TreeSet<Controller> set = new TreeSet<Controller>(controllers.values());
            for (EntityIdent ctrlable : items) {
                for (Controller ctrl : set) {
                    set.remove(ctrl);
                    ctrl.load++;
                    //log.info("Assigning control", "item", ctrlable, "to", ctrl.bodyOid);
                    _orthObj.addToControllers(new EntityControl(ctrlable, ctrl.bodyOid));
                    set.add(ctrl);
                    break;
                }
            }

        } finally {
            _orthObj.commitTransaction();
        }
        return true;
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

    /** Used during the process of controller assignment. */
    protected static class Controller implements Comparable<Controller>
    {
        public final int bodyOid;
        public int load;

        public Controller (int bodyOid) {
            this.bodyOid = bodyOid;
        }
        public boolean equals (Object other) {
            if (other instanceof Controller) {
                Controller that = (Controller) other;
                return (this.bodyOid == that.bodyOid);
            } else {
                return false;
            }
        }
        public int hashCode () {
            return bodyOid;
        }
        public int compareTo (Controller other) {
            // sort first by load, then by body oid
            int diff = Comparators.compare(load, other.load);
            if (diff == 0) {
                diff = Comparators.compare(bodyOid, other.bodyOid);
            }
            return diff;
        }
    } // End: static class Controller

    /** The room object. */
    protected OrthSceneObject _orthObj;

    /** Extra data from scene resolution. */
    protected OrthSceneExtras _extras;

    /** For all MemberInfo's, a mapping of ItemIdent to the member's oid. */
    protected Map<EntityIdent, Integer> _avatarIdents = Maps.newHashMap();

    /** Listens to the room object. */
    protected RoomListener _roomListener = new RoomListener();

    @Inject protected MemorySupply _memSupply;
}
