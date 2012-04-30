//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.entity.client {
import flash.display.DisplayObject;
import flash.geom.Rectangle;

import com.threerings.util.CommandEvent;

import com.threerings.crowd.data.OccupantInfo;

import com.threerings.orth.guild.data.GuildName;
import com.threerings.orth.room.client.RoomContext;
import com.threerings.orth.room.client.RoomController;
import com.threerings.orth.room.data.SocializerInfo;

/**
 * Displays a sprite for a member in a scene.
 */
public class MemberSprite extends ActorSprite
{
    /**
     * Initializes a sprite for the supplied member.
     */
    public function initMemberSprite (occInfo :SocializerInfo, extraInfo :Object) :void
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
        return _module.getInstance(RoomContext).myName.equals(_occInfo.username);
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
        if (super.isNameChangeRequired(oldInfo, newInfo)) {
            return true;
        }

        const oldGuild :GuildName = SocializerInfo(oldInfo).guild;
        const newGuild :GuildName = SocializerInfo(newInfo).guild;
        if (((oldGuild != null) ? oldGuild.guildId : -1) !=
            ((newGuild != null) ? newGuild.guildId : -1)) {
            return true;
        }

        return (SocializerInfo(oldInfo).isAway() != SocializerInfo(newInfo).isAway());
    }

    // from OccupantSprite
    override protected function getSpecialProperty (name :String) :Object
    {
        switch (name) {
        case "member_id":
            return (_occInfo as SocializerInfo).id;

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
}
}
