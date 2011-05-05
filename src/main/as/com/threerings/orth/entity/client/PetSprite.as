//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.entity.client {

import com.threerings.util.CommandEvent;

import com.threerings.orth.room.client.RoomController;
import com.threerings.orth.room.data.PetInfo;
import com.threerings.orth.room.data.PetName;
import com.threerings.orth.ui.OrthNameLabel;

/**
 * Extends {@link ActorSprite} with pet-specific stuff.
 */
public class PetSprite extends ActorSprite
{
    public function initPetSprite (occInfo :PetInfo, extraInfo :Object) :void
    {
        super.initActorSprite(occInfo, extraInfo);
    }

    /**
     * Get the ownerId of this pet.
     */
    public function getOwnerId () :int
    {
        return PetName(_occInfo.username).getOwnerId();
    }

    /**
     * This function sends a chat message to the entire room. Called by our backend
     * in response to a request from usercode.
     */
    public function sendChatMessage (msg :String) :void
    {
        var ctrl :RoomController = getController(true);
        if (ctrl != null) {
            ctrl.sendPetChatMessage(msg, getActorInfo());
        }
    }

    // from ActorSprite
    override public function getDesc () :String
    {
        return "m.pet";
    }

    // from EntitySprite
    override public function getHoverColor () :uint
    {
        return PET_HOVER;
    }

    // from EntitySprite
    override public function hasAction () :Boolean
    {
        return true;
    }

    // from ActorSprite
    override public function toString () :String
    {
        return "PetSprite[" + _occInfo.username + " (oid=" + _occInfo.bodyOid + ")]";
    }

    // from EntitySprite
    override protected function postClickAction () :void
    {
        CommandEvent.dispatch(_sprite, RoomController.PET_CLICKED, this);
    }

    override protected function getSpecialProperty (name :String) :Object
    {
        switch (name) {
        case "member_id":
            return getOwnerId();

        default:
            return super.getSpecialProperty(name);
        }
    }

    // from ActorSprite
    override protected function createBackend () :EntityBackend
    {
        return _module.getInstance(PetBackend);
    }

    // from OccupantSprite
    override protected function createNameLabel () :OrthNameLabel
    {
        return new OrthNameLabel(true);
    }
}
}
