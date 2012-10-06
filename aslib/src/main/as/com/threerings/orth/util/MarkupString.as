//
// Who - Copyright 2010-2011 Three Rings Design, Inc.
package com.threerings.orth.util
{
import flash.text.TextFormat;

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
        const tagReg :RegExp = /\[(\/?)(\w)\]/g;

        var boldLevel :int = 0;
        var italicLevel :int = 0;

        var ix :int = 0;
        while (ix < str.length) {
            const match :Object = tagReg.exec(str);

            const nextIx :int = (match != null) ? match.index : str.length;
            if (nextIx > ix) {
                chunks.push(new MarkupChunk(str.substr(ix, nextIx-ix),
                    italicLevel > 0, boldLevel > 0));
            }
            ix = nextIx;
            if (match != null) {
                var modifier :int = (match[1] == "") ? 1 : -1;
                switch(match[2]) {
                    case "i":
                        italicLevel += modifier;
                        break;
                    case "b":
                        boldLevel += modifier;
                        break;
                    default:
                        // whatever
                        break;
                }

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

import flash.text.TextFormat;

import com.threerings.orth.util.TextUtil;

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
        const newFormat :TextFormat = TextUtil.cloneTextFormat(defaultFormat);
        newFormat.italic = isItalic;
        newFormat.bold = isBold;
        return newFormat;
    }
}
