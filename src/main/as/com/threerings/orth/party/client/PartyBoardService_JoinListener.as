//
// $Id$
package com.threerings.orth.party.client {

import com.threerings.presents.client.InvocationService_InvocationListener;

/**
 * An ActionScript version of the Java PartyBoardService_JoinListener interface.
 */
public interface PartyBoardService_JoinListener
    extends InvocationService_InvocationListener
{
    // from Java PartyBoardService_JoinListener
    function foundParty (arg1 :int, arg2 :String, arg3 :int) :void
}
}
