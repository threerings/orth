//
// $Id: PeepRenderer.as 19627 2010-11-24 16:02:41Z zell $

package com.threerings.orth.party.client {

import flash.events.MouseEvent;

import mx.containers.VBox;
import mx.controls.Label;

import mx.core.ClassFactory;
import mx.core.IFactory;

import flashx.funk.ioc.inject;

import com.threerings.flex.FlexUtil;

import com.threerings.orth.client.PlayerRenderer;
import com.threerings.orth.data.MediaDescSize;
import com.threerings.orth.party.client.PartyDirector;
import com.threerings.orth.party.data.PartyPeep;
import com.threerings.orth.room.client.RoomContext;

public class PeepRenderer extends PlayerRenderer
{
    /**
     * Optional: an object with the following fields:
     * leaderId: (int) the leader of the party.
     */
    public var partyInfo :Object;

    /**
     * Return a factory for use with this renderer.
     */
    public static function createFactory (partyInfo :Object = null) :IFactory
    {
        var cf :ClassFactory = new ClassFactory(PeepRenderer);
        cf.properties = { partyInfo: partyInfo };
        return cf;
    }

    public function PeepRenderer ()
    {
        addEventListener(MouseEvent.CLICK, handleClick);
    }

    override protected function configureUI () :void
    {
        super.configureUI();

        var isLeader :Boolean = (this.data != null) &&
            (partyInfo.leaderId == PartyPeep(this.data).name.getId());
        setStyle("backgroundAlpha", isLeader ? .5 : 0);
        setStyle("backgroundColor", isLeader ? 0x000077 : 0x000000);
    }

    override protected function addCustomControls (content :VBox) :void
    {
        var peep :PartyPeep = PartyPeep(this.data);

        var name :Label = FlexUtil.createLabel(peep.name.toString(), "playerLabel");
        name.width = content.width;
        content.addChild(name);
    }

    protected function handleClick (event :MouseEvent) :void
    {
        if (data != null) {
            _partyDir.popPeepMenu(PartyPeep(data), partyInfo.id);
        }
    }

    override protected function getIconSize () :int
    {
        return MediaDescSize.QUARTER_THUMBNAIL_SIZE;
    }

    protected const _partyDir :PartyDirector = inject(PartyDirector);
}
}
