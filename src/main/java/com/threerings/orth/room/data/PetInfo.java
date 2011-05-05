//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.room.data;

/**
 * Contains published information on a pet in a scene.
 */
public class PetInfo extends ActorInfo
{
    /**
     * Creates an occupant info for the specified pet.
     */
    public PetInfo (PetObject petobj)
    {
        super(petobj);
    }

    @Override // from ActorInfo
    public void updateMedia (ActorObject body)
    {
        PetObject petobj = (PetObject) body;
        _media = petobj.pet.getPetMedia();
        _ident = petobj.pet.getIdent();
    }
}
