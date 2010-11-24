//
// $Id: EntityControl.java 10500 2008-08-07 19:14:38Z mdb $

package com.threerings.orth.scene.data;

import com.threerings.io.SimpleStreamableObject;
import com.threerings.presents.dobj.DSet;

/**
 * Used to coordinate the "control" of a room entity (item). This mechanism elevates one specific
 * client-side instance to play the role usually reserved for server-side logic.
 */
public class EntityControl extends SimpleStreamableObject
    implements DSet.Entry
{
    /** Identifies what is being controlled. */
    public EntityIdent entity;

    /** The body oid of the client in control of this controllable. */
    public int controllerOid;

    /** Used when unserializing. */
    public EntityControl ()
    {
    }

    /** Creates a controller mapping for the specified entity. */
    public EntityControl (EntityIdent entity, int controllerOid)
    {
        this.entity = entity;
        this.controllerOid = controllerOid;
    }

    // from interface DSet.Entry
    public Comparable<?> getKey ()
    {
        return entity;
    }
}
