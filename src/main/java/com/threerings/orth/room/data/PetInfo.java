//
// $Id: PetInfo.java 19760 2010-12-07 23:11:56Z mdb $

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
