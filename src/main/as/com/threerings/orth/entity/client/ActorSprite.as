//
// $Id: ActorSprite.as 19622 2010-11-23 22:59:49Z zell $

package com.threerings.orth.entity.client {

import com.threerings.crowd.data.OccupantInfo;
import com.threerings.orth.data.ClientMediaDesc;
import com.threerings.util.DelayUtil;
import com.threerings.util.Log;
import com.threerings.util.Util;

import com.threerings.orth.data.MediaDesc;
import com.threerings.orth.room.client.RoomController;
import com.threerings.orth.room.client.RoomView;
import com.threerings.orth.room.data.ActorInfo;
import com.threerings.orth.room.data.EntityIdent;
import com.threerings.orth.room.data.OrthLocation;

/**
 * Handles sprites for actors (members and pets).
 */
public class ActorSprite extends OccupantSprite
{
    /**
     * Initializes an actor sprite for the supplied actor.
     */
    public function initActorSprite (occInfo :ActorInfo, extraInfo:Object) :void
    {
        super.initOccupantSprite(occInfo, extraInfo);
    }

    /**
     * Update the actor's state. Called by user code when it wants to change the actor's state.
     */
    public function setState (state :String) :void
    {
        var ctrl :RoomController = getController(true);
        if (ctrl != null && validateUserData(state, null)) {
            ctrl.setActorState(_ident, _occInfo.bodyOid, state);
        }
    }

    /**
     * Get the actor's current state.  Called by user code.
     */
    public function getState () :String
    {
        return getActorInfo().getState();
    }

    /**
     * Returns the actor info for this actor.
     */
    public function getActorInfo () :ActorInfo
    {
        return (_occInfo as ActorInfo);
    }

    /**
     * @return true if we're idle.
     */
    public function isIdle () :Boolean
    {
        return (_occInfo as ActorInfo).isIdle();
    }

    // from OccupantSprite
    override public function getDesc () :String
    {
        return "m.actor";
    }

    // from OccupantSprite
    override public function setOccupantInfo (newInfo :OccupantInfo, extraInfo :Object) :void
    {
        // note whether our state changed (we don't consider it a change if the old info was null,
        // as getting our initial state isn't a "change"); this is reason to have a special
        // state-changed dobj event
        var stateChanged :Boolean =
            (_occInfo != null && !Util.equals((_occInfo as ActorInfo).getState(),
                                              (newInfo as ActorInfo).getState()));

        super.setOccupantInfo(newInfo, extraInfo);

        // note our new item ident, our entity id in the room
        setEntityIdent((newInfo is ActorInfo) ? (newInfo as ActorInfo).getEntityIdent() : null);

        // if the state has changed, dispatch an event
        if (stateChanged) {
            callUserCode("stateSet_v1", getState());
        }
    }

    // from OccupantSprite
    override public function toString () :String
    {
        return "ActorSprite[" + _occInfo.username + " (oid=" + _occInfo.bodyOid + ")]";
    }

    /**
     * Update the actor's scene location. Called by our backend in response to a request from
     * usercode.
     */
    public function setLocationFromUser (x :Number, y :Number, z: Number, orient :Number) :void
    {
        var ctrl :RoomController = getController(true);
        if (ctrl != null) {
            ctrl.requestMove(_ident, new OrthLocation(x, y, z, orient));
        }
    }

    /**
     * Update the actor's orientation.
     * Called by user code when it wants to change the actor's scene location.
     */
    public function setOrientationFromUser (orient :Number) :void
    {
        // TODO
        Log.getLog(this).debug("user-set orientation is currently TODO.");
    }

    public function setMoveSpeedFromUser (speed :Number) :void
    {
        if (!isNaN(speed)) {
            // don't worry, it'll be bounded by the minimum at the appropriate place
            _moveSpeed = speed;
        }
    }

    // from OccupantSprite
    override protected function configureDisplay (
        oldInfo :OccupantInfo, newInfo :OccupantInfo) :Boolean
    {
        // update the item ident
        const oldIdent :EntityIdent = getEntityIdent();
        const newIdent :EntityIdent = ActorInfo(newInfo).getEntityIdent();
        const identChanged :Boolean = !newIdent.equals(oldIdent);
        if (identChanged) {
            var view :RoomView = _sprite.parent as RoomView;
            if (view != null) {
                // indicate that the old entity has left, the new one arrives
                view.dispatchEntityLeft(oldIdent);
                DelayUtil.delayFrame(view.dispatchEntityLeft, [ newIdent ]);
            }

            // and set the new ident
            setEntityIdent(newIdent);
        }

        // check the media
        const newMedia :ClientMediaDesc = (newInfo as ActorInfo).getMedia();
        const mediaChanged :Boolean = !newMedia.equals(_sprite.getMediaDesc());
        if (!mediaChanged && !identChanged) {
            return false; // nothing changed, bail
        }
        if (!mediaChanged) {
            // if the media didn't change, but the ident did, we still need to reload the media
            // so force a change
            _sprite.setMediaDesc(null);
        }
        _sprite.setMediaDesc(newMedia);
        return true; // and indicate to callers that something changed
    }

    // from OccupantSprite
    override protected function appearanceChanged () :void
    {
        var locArray :Array = [ _loc.x, _loc.y, _loc.z ];
        if (hasUserCode("appearanceChanged_v2")) {
            callUserCode("appearanceChanged_v2", locArray, _loc.orient, isMoving(), isIdle());
        } else {
            callUserCode("appearanceChanged_v1", locArray, _loc.orient, isMoving());
        }
    }

    // from EntitySprite
    override protected function createBackend () :EntityBackend
    {
        return _module.getInstance(ActorBackend);
    }
}
}
