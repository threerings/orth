//
// $Id: PlayerRenderer.as 18861 2009-12-17 19:49:18Z zell $

package com.threerings.orth.client {
import mx.containers.HBox;
import mx.containers.VBox;

import mx.core.ScrollPolicy;

import flashx.funk.ioc.inject;

import com.threerings.orth.data.MediaDescSize;
import com.threerings.orth.data.PlayerEntry;
import com.threerings.orth.ui.MediaWrapper;
import com.threerings.orth.room.client.RoomContext;

public class PlayerRenderer extends HBox
{
    public function PlayerRenderer ()
    {
        verticalScrollPolicy = ScrollPolicy.OFF;
        horizontalScrollPolicy = ScrollPolicy.OFF;
    }

    override public function set data (value :Object) :void
    {
        super.data = value;

        if (processedDescriptors) {
            configureUI();
        }
    }

    override protected function createChildren () :void
    {
        super.createChildren();

        // The style name for this renderer isn't getting respected, and I'm through with trying
        // to get it to work, so lets just inline the styles here
        // TODO: This should work, try later
        setStyle("paddingTop", 0);
        setStyle("paddingBottom", 0);
        setStyle("paddingLeft", 3);
        setStyle("paddingRight", 3);
        setStyle("verticalAlign", "middle");
        setStyle("horizontalGap", 0);

        configureUI();
    }

    /**
     * Set up custom content to show for this renderer besides just the profile photo.
     */
    protected function addCustomControls (content :VBox) :void
    {
        // nada
    }

    /**
     * Update the UI elements with the data we're displaying.
     */
    protected function configureUI () :void
    {
        removeAllChildren();

        var player :PlayerEntry = this.data as PlayerEntry;

        if (player != null) {
            var icon :MediaWrapper = MediaWrapper.createView(player.name.getPhoto(), getIconSize());
            addChild(icon);
            var content :VBox = new VBox();
            content.verticalScrollPolicy = ScrollPolicy.OFF;
            content.horizontalScrollPolicy = ScrollPolicy.OFF;
            content.setStyle("verticalGap", 0);
            content.width = parent.width - icon.measuredWidth;
            addChild(content);

            addCustomControls(content);
        }
    }

    /**
     * Get the size of the icon to use for this widget.
     */
    protected function getIconSize () :int
    {
        return MediaDescSize.HALF_THUMBNAIL_SIZE;
    }

    protected const _ctx :OrthContext = inject(OrthContext);
}
}
