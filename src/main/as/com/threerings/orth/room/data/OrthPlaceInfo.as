//
// $Id: PlaceInfo.as 17014 2009-05-29 23:31:28Z jamie $

package com.threerings.orth.room.data {

/**
 * Encapsulates a small amount of information about the place or places the user is currently in.
 * Note that it is possible to be in a room or a game or both or neither.
 */
public class OrthPlaceInfo
{
    /** The id of the scene we are in, or 0 if none. */
    public var sceneId :int;

    /** The name of the scene we are in, or null if none. */
    public var sceneName :String;

    /**
     * Gets the name of the game if we are in a game, otherwise the name of the scene or null if
     * neither.
     */
    public function get name () :String
    {
        return sceneName;
    }

    /**
     * Gets the id of the game if we are in a game, otherwise the id of the scene or null if
     * neither.
     */
    public function get id () :int
    {
        return sceneId;
    }
}
}
