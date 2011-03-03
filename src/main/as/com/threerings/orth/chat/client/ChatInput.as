//
// $Id$

package com.threerings.orth.chat.client {
import flash.display.Sprite;
import flash.events.KeyboardEvent;
import flash.text.TextField;
import flash.text.TextFieldType;

import flashx.funk.ioc.inject;

import com.threerings.crowd.chat.client.ChatDirector;
import com.threerings.text.TextFieldUtil;
import com.threerings.ui.KeyboardCodes;

import com.threerings.util.StringUtil;

import com.threerings.orth.chat.client.OrthChatDirector;

public class ChatInput extends Sprite
{
    public function ChatInput (width :int)
    {
        _root = TextFieldUtil.createField("", {
            textColor: 0x000000, type: TextFieldType.INPUT, width: width, background: true,
            border: true },   { font: "_sans", size: 12, bold: true });

        _root.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
        _root.height = 19; // Sigh
        addChild(_root);
    }

    protected function onKeyDown (event :KeyboardEvent) :void
    {
        if (event.charCode == KeyboardCodes.ENTER && _root.text.length > 0) {
            if (StringUtil.startsWith(_root.text, "/tell")) {
                _chatDir.requestSendTell(0, _root.text);
            } else {
                _chatDir.requestPlaceSpeak(_root.text);
            }
            _root.text = "";
        }
    }

    protected var _root :TextField;

    protected const _chatDir :OrthChatDirector = inject(OrthChatDirector);
}
}
