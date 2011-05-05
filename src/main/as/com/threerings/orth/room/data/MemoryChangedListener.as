//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.
package com.threerings.orth.room.data {

import flash.utils.ByteArray;

import com.threerings.presents.dobj.ChangeListener;

public interface MemoryChangedListener extends ChangeListener
{
    /**
     * Notify us that a memory has changed for this entity. If the value is null,
     * then the memory was removed.
     */
    function memoryChanged (ident :EntityIdent, key :String, value :ByteArray) :void;
}
}
