//
// $Id$
package com.threerings.orth.world.client {

import com.threerings.io.TypedArray;
import com.threerings.presents.client.InvocationService_InvocationListener;

/**
 * An ActionScript version of the Java WorldService_WorldMoveListener interface.
 */
public interface WorldService_WorldMoveListener
    extends InvocationService_InvocationListener
{
    // from Java WorldService_WorldMoveListener
    function moveRequiresServerSwitch (arg1 :String, arg2 :TypedArray /* of int */) :void

    // from Java WorldService_WorldMoveListener
    function moveSucceeded (arg1 :int) :void
}
}
