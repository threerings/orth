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
import com.threerings.orth.entity.data.Walkability;
import com.threerings.orth.ui.MediaDescContainer;

// GENERATED PREAMBLE END
// GENERATED CLASSDECL START
public class MediaWalkability extends Walkability
{
// GENERATED CLASSDECL END

    public function MediaWalkability (media :MediaDesc = null)
    {
        _media = media;
    }

    override public function isPathWalkable (from :Point, to :Point) :Boolean
    {
        // if we've yet to set up the container, do so here
        if (_container == null) {
            // unless there's not even any media, an unlikely situation to be sure
            if (_media == null) {
                return false;
            }
            _container = new MediaDescContainer(_media);
        }
            
        // create a sprite to hold the movement path
        var path :Sprite = new Sprite();
        // draw the path
        path.graphics.moveTo(from.x, from.y);
        path.graphics.lineTo(to.x, to.y);

        // we can walk as long as the path does *not* intersect with the obstruction map
        var map :DisplayObject = _container.getMedia();
        return (map != null) && !map.hitTestObject(path);
    }

// GENERATED STREAMING START
    override public function readObject (ins :ObjectInputStream) :void
    {
        super.readObject(ins);
        _media = ins.readObject(MediaDesc);
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
