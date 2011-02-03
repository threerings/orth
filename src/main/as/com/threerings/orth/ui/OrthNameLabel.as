//
// $Id$

package com.threerings.orth.ui {

import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;

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

        // It's ok that we modify this later, as it gets cloned anyway when assigned to the field.
        _label.defaultTextFormat = FORMAT;
        _label.x = 0;
        addChild(_label);
    }

    /**
     * Update the name based on an OccupantInfo.
     */
    public function update (info :OccupantInfo) :void
    {
        setName(info.username.toString());
        setStatus(info.status, (info is SocializerInfo) && SocializerInfo(info).isAway(), false);
    }

    /**
     * Set the displayed name.
     */
    public function setName (name :String) :void
    { 
        TextFieldUtil.updateText(_label, name);
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

    protected static const FORMAT :TextFormat =
        TextFieldUtil.createFormat({ font: "_sans", size: 12, letterSpacing: .6 });
}
}
