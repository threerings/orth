//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.client {

import com.threerings.orth.ui.FloatingPanel;

import mx.binding.utils.BindingUtils;

import mx.controls.ComboBox;
import mx.controls.Label;
import mx.controls.RadioButton;
import mx.controls.RadioButtonGroup;

import mx.containers.HBox;
import mx.containers.Grid;
import mx.containers.VBox;

import mx.core.UIComponent;

import com.threerings.util.NamedValueEvent;

import com.threerings.flex.CommandButton;
import com.threerings.flex.FlexUtil;
import com.threerings.flex.GridUtil;

/**
 * Displays chat preferences.
 */
public class ChatPrefsDialog extends FloatingPanel
{
    public function ChatPrefsDialog (ctx :OrthContext)
    {
        super(ctx, Msgs.GENERAL.get("t.chat_prefs"));
        showCloseButton = true;
        open(true);

        // listen for preferences changes that happen without us..
        Prefs.events.addEventListener(Prefs.PREF_SET, handlePrefsUpdated, false, 0, true);
    }

    override protected function createChildren () :void
    {
        super.createChildren();

        var tainer :VBox = new VBox();
        tainer.label = Msgs.PREFS.get("t.chat");

        var ii :int;
        var grid :Grid = new Grid();

        GridUtil.addRow(grid, Msgs.PREFS.get("l.chat_size"), createFontSizeControl());

        var decay :ComboBox = new ComboBox();
        var choices :Array = [];
        for (ii = 0; ii < 3; ii++) {
            choices.push(Msgs.PREFS.get("l.chat_decay" + ii));
        }
        decay.dataProvider = choices;
        decay.selectedIndex = Prefs.getChatDecay();
        BindingUtils.bindSetter(Prefs.setChatDecay, decay, "selectedIndex");
        GridUtil.addRow(grid, Msgs.PREFS.get("l.chat_decay"), decay);

        GridUtil.addRow(grid, Msgs.PREFS.get("l.chat_filter"), [2, 1]);
        var filterGroup :RadioButtonGroup = new RadioButtonGroup();
        var filterChoice :int = Prefs.getChatFilterLevel();
        for (ii= 0; ii < 4; ii++) {
            var but :RadioButton = new RadioButton();
            but.label = Msgs.PREFS.get("l.chat_filter" + ii);
            but.selected = (ii == filterChoice);
            but.value = ii;
            but.group = filterGroup;
            var hbox :HBox = new HBox();
            hbox.addChild(FlexUtil.createSpacer(20));
            hbox.addChild(but);
            GridUtil.addRow(grid, hbox, [2, 1]);
        }
        BindingUtils.bindSetter(Prefs.setChatFilterLevel, filterGroup, "selectedValue");

        var lbl :Label = new Label();
        lbl.text = Msgs.PREFS.get("m.chat_filter_note");
        lbl.setStyle("fontSize", 8);
        GridUtil.addRow(grid, lbl, [2, 1]);

        tainer.addChild(grid);
        addChild(tainer);

        addButtons(OK_BUTTON);
    }

    protected function createFontSizeControl () :UIComponent
    {
        _fontTest = new FontTestArea();

        var hbox :HBox = new HBox();

        var bbox :VBox = new VBox();
        _upFont = new CommandButton(null, adjustFont, +1);
        _downFont = new CommandButton(null, adjustFont, -1);
//        _upFont.setStyle("fontSize", 13);
//        _downFont.setStyle("fontSize", 13);
//        _upFont.width = 35;
//        _downFont.width = 35;
        _upFont.styleName = "plusButton";
        _downFont.styleName = "minusButton";
        bbox.addChild(_upFont);
        bbox.addChild(_downFont);

        hbox.addChild(_fontTest);
        hbox.addChild(bbox);
        adjustFont(0); // jiggle everything into place..
        return hbox;
    }

    protected function adjustFont (delta :int) :void
    {
        var size :int = delta + Prefs.getChatFontSize();
        size = Math.max(Prefs.CHAT_FONT_SIZE_MIN, Math.min(Prefs.CHAT_FONT_SIZE_MAX, size));
        Prefs.setChatFontSize(size);

        _upFont.enabled = size < Prefs.CHAT_FONT_SIZE_MAX;
        _downFont.enabled = size > Prefs.CHAT_FONT_SIZE_MIN;
    }

    /**
     * Handle prefs that update some other way, and reflect the changes in the UI.
     */
    protected function handlePrefsUpdated (event :NamedValueEvent) :void
    {
        switch (event.name) {
        case Prefs.CHAT_FONT_SIZE:
            _fontTest.reloadFont();
            break;
        }
    }

    /** A place where the currently configured chat font is tested. */
    protected var _fontTest :FontTestArea;

    protected var _upFont :CommandButton;
    protected var _downFont :CommandButton;
}
}

import com.threerings.orth.chat.client.ChatOverlay;
import com.threerings.orth.client.Msgs;

import flash.text.TextFormat;

import mx.controls.TextArea;


class FontTestArea extends TextArea
{
    public function FontTestArea ()
    {
        text = Msgs.PREFS.get("m.chat_test");
        editable = false;
        minWidth = 200;
        minHeight = 50;
    }

    override protected function createChildren () :void
    {
        super.createChildren();

        reloadFont();
    }

    public function reloadFont () :void
    {
        var tf :TextFormat = ChatOverlay.createChatFormat();

        setStyle("fontSize", tf.size);
        setStyle("fontWeight", tf.bold ? "bold" : "normal");
        setStyle("textAlign", tf.align);
        setStyle("fontStyle", tf.italic ? "italic" : "normal");
        setStyle("color", 0x000000);
        setStyle("fontFamily", tf.font);
    }
}
