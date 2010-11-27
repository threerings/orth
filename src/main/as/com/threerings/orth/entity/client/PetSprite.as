//
// $Id: PetSprite.as 19622 2010-11-23 22:59:49Z zell $

package com.threerings.orth.entity.client {

import com.threerings.orth.room.client.RoomController;
import com.threerings.orth.ui.OrthNameLabel;
import com.threerings.orth.world.client.WorldContext;
import com.threerings.util.CommandEvent;

/**
 * Extends {@link ActorSprite} with pet-specific stuff.
 */
public class PetSprite extends ActorSprite
{
    public function PetSprite (ctx :WorldContext, occInfo :PetInfo, extraInfo :Object)
    {
        super(ctx, occInfo, extraInfo);
    }

    /**
     * Get the ownerId of this pet.
     */
    public function getOwnerId () :int
    {
        return PetName(_occInfo.username).getOwnerId();
    }

    public function isOwnerMuted () :Boolean
    {
        return (_occInfo != null) && _ctx.getMuteDirector() != null &&
            _ctx.getMuteDirector().isOwnerMuted(PetName(_occInfo.username));
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
        return new PetBackend();
    }

    // from OccupantSprite
    override protected function createNameLabel () :OrthNameLabel
    {
        return new OrthNameLabel(true);
    }
}
}
