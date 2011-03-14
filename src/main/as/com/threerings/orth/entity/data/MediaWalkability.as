// GENERATED PREAMBLE START
//
// $Id$

package com.threerings.orth.entity.data {

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.geom.Point;

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

import com.threerings.orth.data.MediaDesc;
import com.threerings.orth.ui.MediaDescContainer;
import com.threerings.orth.entity.data.Walkability;

// GENERATED PREAMBLE END
// GENERATED CLASSDECL START
public class MediaWalkability extends Walkability
{
// GENERATED CLASSDECL END

    public function MediaWalkability (media :MediaDesc = null)
    {
        // we want an initialied container, even if it won't yet hold actual media
        _container = new MediaDescContainer(media);
    }

    override public function isPathWalkable (from :Point, to :Point) :Boolean
    {
        // create a sprite to hold the movement path
        var path :Sprite = new Sprite();
        // draw the path
        path.graphics.moveTo(from.x, from.y);
        path.graphics.lineTo(to.x, to.y);

        // we can walk as long as the path does *not* intersect with the obstruction map
        var media :DisplayObject = _container.getMedia();
        return (media != null) && !media.hitTestObject(path);
    }

// GENERATED STREAMING START
    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        _media = ins.readObject(MediaDesc);
        _container.setMediaDesc(_media);
    }

    override public function writeObject (out :ObjectOutputStream) :void
    {
        super.writeObject(out);
        out.writeObject(_media);
    }

    protected var _media :MediaDesc;
// GENERATED STREAMING END

    protected var _container :MediaDescContainer;

// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END
