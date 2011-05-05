//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.
package com.threerings.orth.entity.data {

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Point;

import com.threerings.media.MediaContainer;

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;

import com.threerings.util.Log;

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

    protected function event (ev :Event = null) :void
    {
        Log.getLog(this).info("LOADING EVENT", "event", event, "media", _container.getMedia(),
            "contentWidth", _container.getContentWidth());
    }

    override public function isPathWalkable (from :Point, to :Point) :Boolean
    {
        // if we've yet to set up the container, do so here
        if (_container == null) {
            Log.getLog(this).info("Setting up media for the first time", "media", _media);
            // unless there's not even any media, an unlikely situation to be sure
            if (_media == null) {
                return false;
            }

            _container = new MediaDescContainer();
            _container.addEventListener(MediaContainer.WILL_SHUTDOWN, event);
            _container.addEventListener(MediaContainer.LOADER_READY, event);
            _container.addEventListener(MediaContainer.SIZE_KNOWN, event);
            _container.addEventListener(MediaContainer.DID_SHOW_NEW_MEDIA, event);
            _container.addEventListener(Event.UNLOAD, event);
            _container.setMediaDesc(_media);
        }

        var map :DisplayObject = _container.getMedia();
        if (map == null) {
            Log.getLog(this).info("Obstruction map still loading, returning false...");
            return false;
        }

        if (_test == null) {
            _test = new Sprite();
            _test.addChild(map);
            Log.getLog(this).info("Adding map to tester", "mapBounds", map.getBounds(_test));
        }

        // draw the path
        _test.graphics.clear();
        _test.graphics.moveTo(from.x, from.y);
        _test.graphics.lineTo(to.x, to.y);

        // we can walk as long as the path does *not* intersect with the obstruction map
        var test :Boolean = !map.hitTestObject(_test);

        if (Math.random() < 0.01) {
            Log.getLog(this).info("Doing hit test", "pathBound", _test.getBounds(_test),
                "mapBounds", map.getBounds(_test), "result", test);
        }

        return test;
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
    protected var _test :Sprite;

// GENERATED CLASSFINISH START
}
}
// GENERATED CLASSFINISH END
