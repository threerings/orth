//
// $Id: Controllable.as 14149 2008-12-31 18:13:55Z mdb $

package com.threerings.orth.room.data {

import com.threerings.io.SimpleStreamableObject;
import com.threerings.util.Equalable;

/**
 * A reference to a client-side executable which can participate in the pseudo-server control
 * mechanism.
 *
 * {@see EntityControl}
 */
public /*abstract*/ class Controllable extends SimpleStreamableObject
    implements Equalable
{
    public function equals (other :Object) :Boolean
    {
        return false;
    }
}
}
