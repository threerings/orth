//
// $Id$
package com.threerings.orth.world.data;

import javax.annotation.Generated;

import com.threerings.orth.world.client.WorldService;
import com.threerings.presents.data.InvocationMarshaller;
import com.threerings.presents.dobj.InvocationResponseEvent;

/**
 * Provides the implementation of the {@link WorldService} interface
 * that marshalls the arguments and delivers the request to the provider
 * on the server. Also provides an implementation of the response listener
 * interfaces that marshall the response arguments and deliver them back
 * to the requesting client.
 */
@Generated(value={"com.threerings.presents.tools.GenServiceTask"},
           comments="Derived from WorldService.java.")
public class WorldMarshaller extends InvocationMarshaller
    implements WorldService
{
    /**
     * Marshalls results to implementations of {@link WorldService.WorldMoveListener}.
     */
    public static class WorldMoveMarshaller extends ListenerMarshaller
        implements WorldMoveListener
    {
        /** The method id used to dispatch {@link #moveRequiresServerSwitch}
         * responses. */
        public static final int MOVE_REQUIRES_SERVER_SWITCH = 1;

        // from interface WorldMoveMarshaller
        public void moveRequiresServerSwitch (String arg1, int[] arg2)
        {
            _invId = null;
            omgr.postEvent(new InvocationResponseEvent(
                               callerOid, requestId, MOVE_REQUIRES_SERVER_SWITCH,
                               new Object[] { arg1, arg2 }, transport));
        }

        /** The method id used to dispatch {@link #moveSucceeded}
         * responses. */
        public static final int MOVE_SUCCEEDED = 2;

        // from interface WorldMoveMarshaller
        public void moveSucceeded (int arg1)
        {
            _invId = null;
            omgr.postEvent(new InvocationResponseEvent(
                               callerOid, requestId, MOVE_SUCCEEDED,
                               new Object[] { Integer.valueOf(arg1) }, transport));
        }

        @Override // from InvocationMarshaller
        public void dispatchResponse (int methodId, Object[] args)
        {
            switch (methodId) {
            case MOVE_REQUIRES_SERVER_SWITCH:
                ((WorldMoveListener)listener).moveRequiresServerSwitch(
                    (String)args[0], (int[])args[1]);
                return;

            case MOVE_SUCCEEDED:
                ((WorldMoveListener)listener).moveSucceeded(
                    ((Integer)args[0]).intValue());
                return;

            default:
                super.dispatchResponse(methodId, args);
                return;
            }
        }
    }

    /** The method id used to dispatch {@link #moveTo} requests. */
    public static final int MOVE_TO = 1;

    // from interface WorldService
    public void moveTo (OrthPlace arg1, WorldService.WorldMoveListener arg2)
    {
        WorldMarshaller.WorldMoveMarshaller listener2 = new WorldMarshaller.WorldMoveMarshaller();
        listener2.listener = arg2;
        sendRequest(MOVE_TO, new Object[] {
            arg1, listener2
        });
    }
}
