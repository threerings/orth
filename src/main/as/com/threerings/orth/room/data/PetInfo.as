//
// $Id: PetInfo.as 15623 2009-03-23 23:46:24Z ray $

package com.threerings.orth.room.data {

/**
 * Contains published information on a pet in a scene.
 */
public class PetInfo extends ActorInfo
{
    // statically reference classes we require
    PetName;

//    /**
//     * Returns the member id of this pet's owner.
//     */
//    public function getOwnerId () :int
//    {
//        return PetName(username).getOwnerId();
//    }

    // from ActorInfo
    override public function clone () :Object
    {
        var that :PetInfo = super.clone() as PetInfo;
        // presently: nothing else to copy
        return that;
    }
}
}
