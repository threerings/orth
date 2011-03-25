//
// $Id: $
//

package com.threerings.orth.chat.client {
import flash.display.Sprite;

public interface ChatGlyph {
    function remove () :void;

    function getChatDrawable () :Sprite;
}
}
