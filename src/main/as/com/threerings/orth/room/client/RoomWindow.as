//
// $Id$
package com.threerings.orth.room.client {

import flash.display.Sprite;
import flash.geom.Point;

import com.threerings.util.Name;

import com.threerings.orth.chat.client.ChatInfoProvider;
import com.threerings.orth.chat.client.SpeakerObserver;
import com.threerings.orth.client.PlaceLayer;

public class RoomWindow extends Sprite
    implements ChatInfoProvider, PlaceLayer
{
    public function RoomWindow (view :RoomView)
    {
        _view = view;

        this.addChild(view);
    }

    public function get roomView () :RoomView
    {
        return _view;
    }

    // from PlaceLayer
    public function setPlaceSize (unscaledWidth :Number, unscaledHeight :Number) :void
    {
        _view.setPlaceSize(unscaledWidth, unscaledHeight);
    }

    // from ChatInfoProvider
    public function getBubblePosition (speaker :Name) :Point
    {
        return _view.getBubblePosition(speaker);
    }

    // from ChatInfoProvider
    public function addBubbleObserver (observer :SpeakerObserver) :void
    {
        _view.addBubbleObserver(observer);
    }

    // from ChatInfoProvider
    public function removeBubbleObserver (observer :SpeakerObserver) :void
    {
        _view.removeBubbleObserver(observer);
    }

    protected var _view :RoomView;
}
}
