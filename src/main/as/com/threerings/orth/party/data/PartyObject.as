//
// $Id: PartyObject.as 19431 2010-10-22 22:08:36Z zell $

package com.threerings.orth.party.data {

import com.threerings.io.ObjectInputStream;

import com.threerings.presents.dobj.DObject;
import com.threerings.presents.dobj.DSet;

import com.threerings.orth.data.MediaDesc;

public class PartyObject extends DObject
{
    // AUTO-GENERATED: FIELDS START
    /** The field name of the <code>id</code> field. */
    public static const ID :String = "id";

    /** The field name of the <code>name</code> field. */
    public static const NAME :String = "name";

    /** The field name of the <code>icon</code> field. */
    public static const ICON :String = "icon";

    /** The field name of the <code>peeps</code> field. */
    public static const PEEPS :String = "peeps";

    /** The field name of the <code>leaderId</code> field. */
    public static const LEADER_ID :String = "leaderId";

    /** The field name of the <code>sceneId</code> field. */
    public static const SCENE_ID :String = "sceneId";

    /** The field name of the <code>gameId</code> field. */
    public static const GAME_ID :String = "gameId";

    /** The field name of the <code>gameState</code> field. */
    public static const GAME_STATE :String = "gameState";

    /** The field name of the <code>gameOid</code> field. */
    public static const GAME_OID :String = "gameOid";

    /** The field name of the <code>status</code> field. */
    public static const STATUS :String = "status";

    /** The field name of the <code>statusType</code> field. */
    public static const STATUS_TYPE :String = "statusType";

    /** The field name of the <code>recruitment</code> field. */
    public static const RECRUITMENT :String = "recruitment";

    /** The field name of the <code>disband</code> field. */
    public static const DISBAND :String = "disband";

    /** The field name of the <code>partyService</code> field. */
    public static const PARTY_SERVICE :String = "partyService";
//
//    /** The field name of the <code>speakService</code> field. */
//    public static const SPEAK_SERVICE :String = "speakService";
    // AUTO-GENERATED: FIELDS END

    /** A message sent to indicate a notification that should be dispatched to all partiers.
     * Format: [ Notification ]. */
    public static const NOTIFICATION :String = "notification";

    /** This party's guid. */
    public var id :int;

    /** The name of this party. */
    public var name :String;

    /** The icon for this party. */
    public var icon :MediaDesc;

    /** The list of people in this party. */
    public var peeps :DSet; /* of */ PartyPeep; // link the class in. :)

    /** The member ID of the current leader. */
    public var leaderId :int;

    /** The current location of the party. */
    public var sceneId :int;

    /** Customizable flavor text. */
    public var status :String;

    /** Helps interpret the status. */
    public var statusType :int;

    /** This party's access control. @see PartyCodes */
    public var recruitment :int;

    /** Do we disband when the leader leaves? */
    public var disband :Boolean;

    /** The service for doing things on this party. */
    public var partyService :PartyMarshaller;

//    /** Speaking on this party object. */
//    public var speakService :SpeakMarshaller;

    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);

        id = ins.readInt();
        name = ins.readField(String) as String;
        icon = MediaDesc(ins.readObject());
        peeps = DSet(ins.readObject());
        leaderId = ins.readInt();
        sceneId = ins.readInt();
        status = ins.readField(String) as String;
        statusType = ins.readByte();
        recruitment = ins.readByte();
        disband = ins.readBoolean();
        partyService = PartyMarshaller(ins.readObject());
//        speakService = SpeakMarshaller(ins.readObject());
    }
}
}
