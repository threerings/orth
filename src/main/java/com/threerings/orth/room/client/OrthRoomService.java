package com.threerings.orth.room.client;

import com.threerings.presents.client.Client;
import com.threerings.presents.client.InvocationService;

import com.threerings.whirled.spot.data.Location;

import com.threerings.orth.room.data.EntityIdent;

public interface OrthRoomService extends InvocationService
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
    void sendSpriteMessage (Client client, EntityIdent item, String name,
        byte[] arg, boolean isAction);

    /**
     * Requests to send a sprite signal.
     *
     * @param name the message name.
     * @param arg the data
     */
    void sendSpriteSignal (Client client, String name, byte[] arg);

    /**
     * Requests to update an actor's state.
     */
    void setActorState (Client client, EntityIdent item, int actorOid, String state);

    /**
     * Issues a request to update the memory of the specified entity (which is associated with a
     * particular item).
     */
    void updateMemory (Client client, EntityIdent ident, String key,
        byte[] newValue, ResultListener listener);

    /**
     * Issues a request to update the current scene location of the specified item. This is called
     * by Pets and other MOBs that want to move around the room.
     */
    void changeLocation (Client client, EntityIdent item, Location newloc);
}
