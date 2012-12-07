//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.ui {
import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;

import com.threerings.util.F;

import com.threerings.crowd.data.OccupantInfo;

import com.threerings.text.TextFieldUtil;

import com.threerings.orth.room.data.SocializerInfo;

public class OrthNameLabel extends Sprite
{
    public function OrthNameLabel (ignoreStatus :Boolean = false)
    {
        _ignoreStatus = ignoreStatus;

        // TODO: the outline trick just barely works here, perhaps it is time to consider a
        // different solution, including using different code for avatars and occupant list
        _label = TextFieldUtil.createField("",
            { textColor: 0xFFFFFF, selectable: false, autoSize :TextFieldAutoSize.LEFT,
            outlineColor: 0x000000, outlineWidth: 5, outlineStrength: 12 });

        _title = TextFieldUtil.createField("",
            { textColor: 0xFFFFFF, selectable: false, autoSize :TextFieldAutoSize.LEFT,
            outlineColor: 0x000000, outlineWidth: 5, outlineStrength: 12 });

        _guild = TextFieldUtil.createField("",
            { textColor: 0xFFFFFF, selectable: false, autoSize :TextFieldAutoSize.LEFT,
            outlineColor: 0x000000, outlineWidth: 5, outlineStrength: 12 });

        // It's ok that we modify this later, as it gets cloned anyway when assigned to the field.
        _label.defaultTextFormat = FORMAT;
        _guild.defaultTextFormat = FORMAT;
        _title.defaultTextFormat = FORMAT;

        addChild(_label);
        addChild(_title);
        addChild(_guild);
    }

    /**
     * Update the name based on an OccupantInfo.
     */
    public function update (info :OccupantInfo) :void
    {
        TextFieldUtil.updateText(_label, info.username.toString());
        var guildName :String = "";
        var title :String = "";
        var titleColor :uint;
        if ((info is SocializerInfo) && SocializerInfo(info).guild != null) {
            _guild.visible = true;
            guildName = "<" + SocializerInfo(info).guild.toString() + ">";
        } else {
            _guild.visible = false;
        }

        if ((info is SocializerInfo) && SocializerInfo(info).title != null) {
            _title.visible = true;
            title = SocializerInfo(info).title;
        } else {
            _title.visible = false;
        }

        if (gTitles.indexOf(title, 0) != -1 ) {
            titleColor = 0x45fe83;
        } else if (dTitles.indexOf(title, 0) != -1) {
            titleColor = 0x8073ed;
        } else if (tTitles.indexOf(title, 0) != -1) {
            titleColor = 0xfed26d;
        } else if (aTitles.indexOf(title, 0) != -1) {
            titleColor = 0xe4743e;
        } else {
            titleColor = 0xa2a5aa;
        }

        TextFieldUtil.updateText(_guild, guildName);
        TextFieldUtil.updateText(_title, title.toUpperCase());
        _title.textColor = titleColor;

        setStatus(info.status, (info is SocializerInfo) && SocializerInfo(info).isAway(), false);

        const center :Number = Math.max(_label.textWidth, _guild.textWidth) / 2;
        _label.x = center - (_label.textWidth / 2);
        _title.x = center - (_title.textWidth / 2);
        _title.y = _label.y + _label.textHeight + 2;
        _guild.x = center - (_guild.textWidth / 2);
        _guild.y = _title.y + _title.textHeight + 2;
    }

    /**
     * Updates our player's status (idle, disconnected, etc.).
     */
    public function setStatus (status :int, away :Boolean, italicize :Boolean) :void
    {
        if (_ignoreStatus) {
            return;
        }

        if (away) {
            _label.textColor = 0xFFFF77;
        } else if (status == OccupantInfo.IDLE) {
            _label.textColor = 0x777777;
        } else if (status == OccupantInfo.DISCONNECTED) {
            _label.textColor = 0x80803C;
        } else {
            _label.textColor = 0x99BFFF;
        }

        // turn on or off italicizing.
        TextFieldUtil.updateFormat(_label, { italic: italicize });
    }

    protected var _ignoreStatus :Boolean;

    protected var _label :TextField;
    protected var _guild :TextField;
    protected var _title :TextField;

    protected static const FORMAT :TextFormat =
        TextFieldUtil.createFormat({ font: "_sans", size: 12, letterSpacing: .6 });

    protected static const gTitles :Array = ["Novice", "Defender", "Protector", "Warrior",
        "Warden", "Captain", "Major", "Brigadier", "Champion", "Sentinel", "Centurion"];
    protected static const tTitles :Array = ["Tinkerer", "Fixer", "Hacker", "Sabateur",
        "Operative", "Engineer", "Architect", "Inventor", "Scientist", "Mastermind", "Time Agent"];
    protected static const dTitles :Array = ["Advocate", "Companion", "Mediator", "Negotiator",
        "Scholar", "Librarian", "Professor", "Detective", "Alienist", "Councilor", "Oracle"];
    protected static const aTitles :Array = ["Wanderer", "Traveler", "Pilgrim", "Pioneer",
        "Explorer", "Archaeologist", "Swashbuckler", "Voyager", "Astronaut", "Guide", "Questor"];
}
}
