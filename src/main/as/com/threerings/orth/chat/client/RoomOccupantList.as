//
// $Id: RoomOccupantList.as 19627 2010-11-24 16:02:41Z zell $

package com.threerings.orth.chat.client {

import mx.core.mx_internal;

import com.whirled.ui.NameLabelCreator;
import com.whirled.ui.PlayerList;

import com.threerings.presents.dobj.DSet_Entry;
import com.threerings.presents.dobj.EntryAddedEvent;
import com.threerings.presents.dobj.EntryRemovedEvent;
import com.threerings.presents.dobj.EntryUpdatedEvent;
import com.threerings.presents.dobj.SetListener;

import com.threerings.crowd.data.OccupantInfo;
import com.threerings.crowd.data.PlaceObject;

import com.threerings.orth.client.OrthContext;
import com.threerings.orth.data.VizOrthName;
import com.threerings.orth.room.data.PlayerInfo;
import com.threerings.orth.ui.OrthNameLabelCreator;

/**
 * Displays a list of room occupants.
 */
public class RoomOccupantList extends PlayerList
    implements SetListener
{
    public function RoomOccupantList (ctx :OrthContext)
    {
        super(new OrthNameLabelCreator(ctx, true));

        _list.mouseEnabled = false;
        _list.mx_internal::getListContentHolder().mouseEnabled = false;
        mouseEnabled = false;
    }

    public function havePlace () :Boolean
    {
        return _plobj != null;
    }

    public function setPlaceObject (plobj: PlaceObject) :void
    {
        if (_plobj != null) {
            // clear out our old place
            _plobj.removeListener(this);
            _plobj = null;
            // clear out any occupants in our list
            clear();
        }

        if (plobj != null) {
            // listen for changes on our place object
            _plobj = plobj;
            _plobj.addListener(this);

            // set up our current occupants
            for each (var occInfo :OccupantInfo in plobj.occupantInfo.toArray()) {
                processOccupant(occInfo, addItem);
            }
        }
    }

    // from interface SetListener
    public function entryAdded (event :EntryAddedEvent) :void
    {
        if (event.getName() == PlaceObject.OCCUPANT_INFO) {
            processOccupant(event.getEntry(), addItem);
        }
    }

    // from interface SetListener
    public function entryUpdated (event :EntryUpdatedEvent) :void
    {
        if (event.getName() == PlaceObject.OCCUPANT_INFO) {
            processOccupant(event.getEntry(), itemUpdated);
        }
    }

    // from interface SetListener
    public function entryRemoved (event :EntryRemovedEvent) :void
    {
        if (event.getName() == PlaceObject.OCCUPANT_INFO) {
            processOccupant(event.getOldEntry(), removeItem);
        }
    }

    /**
     * Filter out non-members, and puppets.
     */
    protected function processOccupant (entry :DSet_Entry, fn :Function) :void
    {
        if ((entry is PlayerInfo) && (PlayerInfo(entry).username is VizOrthName)) {
            fn(new RoomOccupantRecord(entry as OccupantInfo));
        }
    }

    override protected function getRenderingClass () :Class
    {
        return RoomOccupantRenderer;
    }

    protected var _plobj :PlaceObject;
}
}

import flash.display.DisplayObject;

import mx.containers.HBox;

import mx.core.ScrollPolicy;

import com.threerings.util.Comparable;
import com.threerings.util.Hashable;
import com.threerings.util.Name;

import com.threerings.crowd.data.OccupantInfo;

import com.whirled.ui.NameLabel;
import com.whirled.ui.NameLabelCreator;

import com.threerings.orth.data.OrthName;

import com.threerings.orth.data.OrthUserOccupantInfo;
import com.threerings.orth.data.VizOrthName;

class RoomOccupantRecord
    implements Hashable, Comparable
{
    /** The username. */
    public var name :Name;

    public function RoomOccupantRecord (occInfo :OccupantInfo)
    {
        this.name = occInfo.username;
    }

    // from Hashable
    public function hashCode () :int
    {
        return name.hashCode();
    }

    // from Equalable (via Hashable)
    public function equals (other :Object) :Boolean
    {
        return (other is RoomOccupantRecord) && name.equals(RoomOccupantRecord(other).name);
    }

    // from Comparable
    public function compareTo (other :Object) :int
    {
        var that :RoomOccupantRecord = RoomOccupantRecord(other);
        return OrthName.BY_DISPLAY_NAME(this.name, that.name);
    }
}

class RoomOccupantRenderer extends HBox
{
    public function RoomOccupantRenderer ()
    {
        super();

        verticalScrollPolicy = ScrollPolicy.OFF;
        horizontalScrollPolicy = ScrollPolicy.OFF;
        setStyle("backgroundAlpha", 0);
        mouseEnabled = false;
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

        configureUI();
    }

    protected function configureUI () :void
    {
        if (this.data != null && (this.data is Array) && (this.data as Array).length == 2) {
            var dataArray :Array = this.data as Array;
            var creator :NameLabelCreator = dataArray[0] as NameLabelCreator;
            var record :RoomOccupantRecord = dataArray[1] as RoomOccupantRecord;
            var name :VizOrthName = record.name as VizOrthName;
            if (_currentName == null || !_currentName.equals(name) ||
                    _currentName.toString() != name.toString() ||
                    !_currentName.getPhoto().equals(name.getPhoto())) {
                if (_currentLabel != null && contains(DisplayObject(_currentLabel))) {
                    removeChild(DisplayObject(_currentLabel));
                }
                _currentLabel = creator.createLabel(name);
                addChild(DisplayObject(_currentLabel));
                _currentLabel.percentWidth = 100;
                _currentName = name;
            }
        } else {
            if (_currentLabel != null && contains(DisplayObject(_currentLabel))) {
                removeChild(DisplayObject(_currentLabel));
            }
            _currentLabel = null;
            _currentName = null;
        }
    }

    protected var _currentLabel :NameLabel;
    protected var _currentName :VizOrthName;
}
