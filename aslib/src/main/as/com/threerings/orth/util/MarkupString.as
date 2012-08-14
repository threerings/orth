//
// Who - Copyright 2010-2011 Three Rings Design, Inc.
package com.threerings.orth.util
{
import com.threerings.util.Map;
import com.threerings.util.Maps;

import flash.text.TextFormat;
import flash.utils.Dictionary;

/**
 * A type-safe representation of simple formatted strings.
 */
public class MarkupString
{
    /**
     * Accepts a [i]marked-up strings[/i] and returns a MarkupString.
     */
    public static function parseString (str :String) :MarkupString
    {
        const chunks :Array = [ ];
        const formats :Dictionary = new Dictionary();
        const tagReg :RegExp = /\[(\/?)(\w)\]/g;

        var ix :int = 0;
        while (ix < str.length) {
            const match :Object = tagReg.exec(str);

            const nextIx :int = (match != null) ? match.index : str.length;
            if (nextIx > ix) {
                chunks.push(new MarkupChunk(str.substr(ix, nextIx-ix),
                    formats["i"] > 0, formats["b"] > 0));
            }
            ix = nextIx;
            if (match != null) {
                formats[match[2]] = int(formats[match[2]]) + (match[1] == "/") ? -1 : 1;
                ix += match[0].length;
            }
        }
        return new MarkupString(chunks);
    }

    public function toTexts (defaultFormat :TextFormat) :Array
    {
        const texts :Array = [ ];
        for each (var chunk :MarkupChunk in _chunks) {
            texts.push(chunk.getTextFormat(defaultFormat), chunk.str);
        }
        return texts;
    }

    function MarkupString (chunks :Array)
    {
        _chunks = chunks;
    }

    protected var _chunks :Array;
}
}

import com.threerings.orth.util.TextUtil;

import flash.text.TextFormat;

class MarkupChunk
{
    public var str :String;
    public var isItalic :Boolean;
    public var isBold :Boolean;

    public function MarkupChunk (str :String, isItalic :Boolean, isBold :Boolean)
    {
        this.str = str;
        this.isItalic = isItalic;
        this.isBold = isBold;
    }

    public function getTextFormat (defaultFormat :TextFormat) :TextFormat
    {
        if (isItalic || isBold) {
            const newFormat :TextFormat = TextUtil.cloneTextFormat(defaultFormat);
            newFormat.italic = isItalic;
            newFormat.bold = isBold;
            return newFormat;
        }
        return defaultFormat;
    }
}
