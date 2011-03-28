//
// $Id: MemberSprite.as 19627 2010-11-24 16:02:41Z zell $

package com.threerings.orth.entity.client {
import flash.display.DisplayObject;
import flash.geom.Rectangle;

import com.threerings.crowd.data.OccupantInfo;

import com.threerings.util.CommandEvent;

import com.threerings.orth.room.client.RoomController;
import com.threerings.orth.room.data.SocializerInfo;
import com.threerings.orth.locus.client.LocusContext;

/**
 * Displays a sprite for a member in a scene.
 */
public class MemberSprite extends ActorSprite
{
    /**
     * Initializes a sprite for the supplied member.
     */
    public function initMemberSprite (occInfo :SocializerInfo, extraInfo :Object):void
    {
        super.initActorSprite(occInfo, extraInfo);
    }

    /**
     * Get a list of the names of special actions that this avatar supports.
     */
    public function getAvatarActions () :Array
    {
        return validateActionsOrStates(callUserCode("getActions_v1") as Array);
    }

    /**
     * Get a list of the names of the states that this avatar may be in.
     */
    public function getAvatarStates () :Array
    {
        return validateActionsOrStates(callUserCode("getStates_v1") as Array);
    }

    /**
     * Get our preferred y value for positioning.
     */
    public function getPreferredY () :int
    {
        return int(Math.round(_scale * _preferredY));
    }

    /**
     * Informs the avatar that the player it represents just spoke.
     */
    public function performAvatarSpoke () :void
    {
        callUserCode("avatarSpoke_v1");
    }

    // from RoomElement
    override public function isImportant () :Boolean
    {
        // our own sprite is more important than the others
        return _module.getInstance(LocusContext).getMyName().equals(_occInfo.username);
    }

    // from OccupantSprite
    override public function setOccupantInfo (newInfo :OccupantInfo, extraInfo :Object) :void
    {
        super.setOccupantInfo(newInfo, extraInfo);

        // take care of setting up or changing our PartyIcon
        var newId :int = (newInfo as SocializerInfo).getPartyId();
        if (_partyIcon != null && (_partyIcon.id != newId)) {
            _partyIcon.shutdown();
            _partyIcon = null;
        }
        if (_partyIcon == null && newId != 0) {
            _partyIcon = new PartyIcon(this, newId, extraInfo);
        }
    }

    // from ActorSprite
    override public function getDesc () :String
    {
        return "m.avatar";
    }

    // from EntitySprite
    override public function getHoverColor () :uint
    {
        return AVATAR_HOVER;
    }

    // from EntitySprite
    override public function hasAction () :Boolean
    {
        return true;
    }

    // from OccupantSprite
    override protected function isNameChangeRequired (oldInfo :OccupantInfo,
                                                      newInfo :OccupantInfo) :Boolean
    {
        return super.isNameChangeRequired(oldInfo, newInfo) || // is true if oldInfo == null
            (SocializerInfo(oldInfo).isAway() != SocializerInfo(newInfo).isAway());
    }

    // from OccupantSprite
    override protected function getSpecialProperty (name :String) :Object
    {
        switch (name) {
        case "member_id":
            return (_occInfo as SocializerInfo).getPlayerId();

        default:
            return super.getSpecialProperty(name);
        }
    }

    // from ActorSprite
    override public function toString () :String
    {
        return "MemberSprite[" + _occInfo.username + " (oid=" + _occInfo.bodyOid + ")]";
    }

    // from OccupantSprite
    override protected function configureDisplay (
        oldInfo :OccupantInfo, newInfo :OccupantInfo) :Boolean
    {
        // update our scale
        var oldScale :Number = _scale;
        _scale = (newInfo as SocializerInfo).getScale();

        // see if our media has been updated
        var changed :Boolean = super.configureDisplay(oldInfo, newInfo);

        // if scale is the only thing that changed, make sure we report changedness
        if (!changed && oldScale != _scale) {
            scaleUpdated();
        }

        return changed || (oldScale != _scale);
    }

    // from OccupantSprite
    override protected function configureDecorations (
        oldInfo :OccupantInfo, newInfo :OccupantInfo) :Boolean
    {
        var reconfig :Boolean = super.configureDecorations(oldInfo, newInfo);

        // check whether our idle status has changed
        if (isVisiblyIdle(newInfo as SocializerInfo) == (_idleIcon == null)) {
            if (_idleIcon == null) {
                _idleIcon = _rsrc.newIdleIcon();
                addDecoration(_idleIcon, {
                    weight: OccupantSprite.DEC_WEIGHT_IDLE,
                    bounds: new Rectangle(0, 0, 50, 45)
                });
            } else {
                removeDecoration(_idleIcon);
                _idleIcon = null;
            }
            appearanceChanged();
            reconfig = false; // we took care of rearranging our decorations
        }

        return reconfig;
    }

    // from ActorSprite
    override protected function postClickAction () :void
    {
        CommandEvent.dispatch(_sprite, RoomController.AVATAR_CLICKED, this);
    }

    // from ActorSprite
    override protected function createBackend () :EntityBackend
    {
        _preferredY = 0;
        return _module.getInstance(AvatarBackend);
    }

    /**
     * Verify that the actions or states received from usercode are not wacky.
     *
     * @return the cleaned Array, which may be empty things didn't check out.
     */
    protected function validateActionsOrStates (vals :Array) :Array
    {
        if (vals == null) {
            return [];
        }
        // If there are duplicates, non-strings, or strings.length > 64, then the
        // user has bypassed the checks in their Control and we just discard everything.
        for (var ii :int = 0; ii < vals.length; ii++) {
            if (!validateUserData(vals[ii], null)) {
                return [];
            }
            // reject duplicates
            for (var jj :int = 0; jj < ii; jj++) {
                if (vals[jj] === vals[ii]) {
                    return [];
                }
            }
        }
        // everything checks out...
        return vals;
    }

    // don't show our idleness if we're AFK
    protected function isVisiblyIdle (info :SocializerInfo) :Boolean
    {
        return (info.status == OccupantInfo.IDLE) && !info.isAway();
    }

    /**
     * Routed from usercode by our backend.
     */
    internal function setPreferredYFromUser (prefY :int) :void
    {
        _preferredY = prefY;
    }

    /** The preferred y value, in pixels, when a user selects a location. */
    protected var _preferredY :int

    /** A decoration added when we've idled out. */
    protected var _idleIcon :DisplayObject;

    /** A decoration used when we're in a party. */
    protected var _partyIcon :PartyIcon;
}
}

import flash.geom.Rectangle;

import com.threerings.util.Log;

import com.threerings.orth.client.OrthController;
import com.threerings.orth.data.MediaDescSize;
import com.threerings.orth.entity.client.EntitySprite;
import com.threerings.orth.entity.client.MemberSprite;
import com.threerings.orth.entity.client.OccupantSprite;
import com.threerings.orth.party.data.PartySummary;
import com.threerings.orth.ui.GlowSprite;
import com.threerings.orth.ui.ScalingMediaDescContainer;

class PartyIcon extends GlowSprite
{
    /** The party id. */
    public var id :int;

    public function PartyIcon (host :MemberSprite, partyId :int, extraInfo :Object)
    {
        _host = host;
        id = partyId;

        var summ :PartySummary = extraInfo.parties.get(partyId) as PartySummary;
        if (summ == null) {
            Log.getLog(this).warning("Ohnoez, couldn't set up PartyIcon.");
            return;
        }

        _icon = ScalingMediaDescContainer.createView(
            summ.icon, MediaDescSize.QUARTER_THUMBNAIL_SIZE);
        _icon.x = _icon.maxW / -2; // position with 0 at center
        addChild(_icon);

        init(EntitySprite.OTHER_HOVER, OrthController.GET_PARTY_DETAIL, summ.id);

        var width :int = _icon.maxW;
        var height :int = _icon.maxH
        // specify our bounds explicitly, as our width is centered at 0.
        _host.addDecoration(this, {
              toolTip: summ.name,
              weight: OccupantSprite.DEC_WEIGHT_PARTY,
              bounds: new Rectangle(width/-2, 0, width, height)
        });
    }

    public function shutdown () :void
    {
        _icon.shutdown();
        _host.removeDecoration(this);
    }

    protected var _host :MemberSprite;
    protected var _icon :ScalingMediaDescContainer;
}
