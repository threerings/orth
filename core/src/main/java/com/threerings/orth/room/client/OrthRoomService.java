//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.room.client;

import com.threerings.presents.client.InvocationService;
import com.threerings.presents.data.ClientObject;

import com.threerings.whirled.data.SceneUpdate;
import com.threerings.whirled.spot.data.Location;

import com.threerings.orth.room.data.EntityIdent;

public interface OrthRoomService extends InvocationService<ClientObject>
{
    /**
     * Requests to send a sprite message.
     *
     * @param item the identifier of the item on which to trigger the event, or null if it should
     * be delivered to all items.
     * @param name the message name.
     * @param arg the data
     * @param isAction if the message is a "action".
     */
    void sendSpriteMessage (EntityIdent item, String name, byte[] arg, boolean isAction);

    /**
     * Requests to send a sprite signal.
     *
     * @param name the message name.
     * @param arg the data
     */
    void sendSpriteSignal (String name, byte[] arg);

    /**
     * Requests to update an actor's state.
     */
    void setActorState (EntityIdent item, int actorOid, String state);

    /**
     * Requests to edit the client's current room.
     *
     * @param listener will be informed with an array of items in the room.
     */
    void editRoom (ResultListener listener);

    /**
     * Requests to apply the specified scene update to the room.
     */
    void updateRoom (SceneUpdate update, InvocationListener listener);

    /**
     * Issues a request to update the memory of the specified entity (which is associated with a
     * particular item).
     */
    void updateMemory (EntityIdent ident, String key, byte[] newValue, ResultListener listener);

    /**
     * Issues a request to update the current scene location of the specified item. This is called
     * by Pets and other MOBs that want to move around the room.
     */
    void changeLocation (EntityIdent item, Location newloc);
}
