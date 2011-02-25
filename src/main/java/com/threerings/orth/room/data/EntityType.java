//
// $Id: $


package com.threerings.orth.room.data;

import com.samskivert.util.ByteEnum;

import com.threerings.io.Streamable;
import com.threerings.util.ActionScript;

/** An opaque entity type which each project should implement as a {@link ByteEnum}. */
@ActionScript(omit=true)
public interface EntityType
    extends ByteEnum, Streamable
{
}
