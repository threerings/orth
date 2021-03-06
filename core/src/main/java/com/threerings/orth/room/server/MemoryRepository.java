//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.room.server;

import java.util.List;
import java.util.Set;

import com.threerings.orth.room.data.EntityIdent;
import com.threerings.orth.room.data.EntityMemories;

/**
* Implementing projects would bind this to e.g. a database repository.
*/
public interface MemoryRepository
{
    List<EntityMemories> loadMemories (Set<EntityIdent> memoryIds);
    void flushMemories (Iterable<EntityMemories> memories);
}
