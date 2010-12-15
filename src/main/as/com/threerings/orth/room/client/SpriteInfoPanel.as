//
// $Id$

package com.threerings.orth.room.client {
import com.threerings.orth.client.Msgs;
import com.threerings.orth.client.Prefs;
import com.threerings.orth.entity.client.EntitySprite;
import com.threerings.orth.room.data.EntityIdent;
import com.threerings.orth.room.data.EntityType;
import com.threerings.orth.ui.FloatingPanel;
import com.threerings.orth.world.client.WorldContext;
import com.threerings.orth.world.client.WorldControlBar;

import mx.collections.ArrayCollection;
import mx.controls.List;
import mx.core.ClassFactory;
import mx.core.ScrollPolicy;

import com.threerings.io.TypedArray;

import com.threerings.flex.CommandButton;


/**
 * Shows info on a bunch of sprites.
 */
public class SpriteInfoPanel extends FloatingPanel
{
    /**
     * A predicate indicating if the specified ident is kosher to pass to getItemNames()?
     */
    public static function isRealIdent (ident :EntityIdent) :Boolean
    {
        return (ident != null) && (ident.getType() != null) && (ident.getItem() != 0);
    }

    /**
     * Construct a SpriteInfoPanel.
     */
    public function SpriteInfoPanel (ctx :WorldContext, sprites :Array /* of EntitySprite */)
    {
        super(ctx, Msgs.WORLD.get("t.item_info"));
        showCloseButton = true;

        var idents :TypedArray = TypedArray.create(EntityIdent);
        // wrap each sprite inside an array so that we can fill in the names later
        var data :Array = sprites.map(function (sprite :EntitySprite, ... ignored) :Array {
            // sneak-build the idents array
            var ident :EntityIdent = sprite.getEntityIdent();
            if (isRealIdent(ident)) {
                idents.push(ident);
            }
            return [ sprite ];
        });
        _data.source = data;

        _list = new List();
        _list.horizontalScrollPolicy = ScrollPolicy.OFF;
        _list.verticalScrollPolicy = ScrollPolicy.ON;
        _list.selectable = false;
        _list.itemRenderer = new ClassFactory(SpriteInfoRenderer);
        _list.dataProvider = _data;
        addChild(_list);

        var svc :ItemService = ctx.getClient().requireService(ItemService) as ItemService;
        svc.getItemNames(idents, ctx.resultListener(gotItemNames));
    }

    override protected function didOpen () :void
    {
        super.didOpen();

        // make sure we're not highlighting all items, it screws with our hover highlight
        var btn :CommandButton = WorldControlBar(_ctx.getControlBar()).hotZoneBtn;
        if (btn.selected) {
            btn.activate();
        }
    }

    /**
     * A result handler for the service request we make.
     */
    protected function gotItemNames (names :Array /* of String */) :void
    {
        // trek through the array, pushing on the name for any idents that we passed to the service
        for each (var data :Array in _data.source) {
            if (isRealIdent(EntitySprite(data[0]).getEntityIdent())) {
                data.push(names.shift());
            }
        }
        _data.refresh();
    }

    protected var _list :List;

    protected var _data :ArrayCollection = new ArrayCollection();
}
}

import com.threerings.orth.client.Msgs;
import com.threerings.orth.entity.client.EntitySprite;
import com.threerings.orth.room.client.SpriteInfoPanel;
import com.threerings.orth.room.data.EntityIdent;
import com.threerings.orth.world.client.WorldController;

import flash.events.MouseEvent;

import mx.containers.HBox;
import mx.controls.Label;
import mx.core.ScrollPolicy;

import com.threerings.flex.CommandButton;

class SpriteInfoRenderer extends HBox
{
    public function SpriteInfoRenderer ()
    {
        horizontalScrollPolicy = ScrollPolicy.OFF;
        verticalScrollPolicy = ScrollPolicy.OFF;

        _type = new Label();
        _type.width = 60;

        _name = new Label();
        _name.width = 160;

        _info = new CommandButton(Msgs.GENERAL.get("b.view_info"));

        addEventListener(MouseEvent.ROLL_OVER, handleRoll);
        addEventListener(MouseEvent.ROLL_OUT, handleRoll);
    }

    override public function set data (value :Object) :void
    {
        super.data = value;

        var arr :Array = value as Array;

        var sprite :EntitySprite = arr[0];
        _type.text = Msgs.GENERAL.get(sprite.getDesc());

        var ident :EntityIdent = sprite.getEntityIdent();
        _info.setCommand(WorldController.VIEW_ITEM, ident);
        _info.enabled = SpriteInfoPanel.isRealIdent(ident);

        var name :String = arr[1];
        _name.text = name;
    }

    override protected function createChildren () :void
    {
        super.createChildren();

        setStyle("paddingTop", 0);
        setStyle("paddingBottom", 0);
        setStyle("paddingLeft", 3);
        setStyle("paddingRight", 3);
        setStyle("verticalAlign", "middle");

        addChild(_type);
        addChild(_name);
        addChild(_info);
    }

    protected function handleRoll (event :MouseEvent) :void
    {
        EntitySprite(data[0]).setHovered(event.type == MouseEvent.ROLL_OVER);
    }

    protected var _type :Label;
    protected var _name :Label;
    protected var _info :CommandButton;
}
