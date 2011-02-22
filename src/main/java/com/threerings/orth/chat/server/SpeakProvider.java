//
// $Id$
package com.threerings.orth.chat.server;

import javax.annotation.Generated;

import com.threerings.orth.chat.client.SpeakService;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.server.InvocationProvider;

/**
 * Defines the server-side of the {@link SpeakService}.
 */
@Generated(value={"com.threerings.presents.tools.GenServiceTask"},
           comments="Derived from SpeakService.java.")
public interface SpeakProvider extends InvocationProvider
{
    /**
     * Handles a {@link SpeakService#speak} request.
     */
    void speak (ClientObject caller, String arg1);
}
