//
// $Id$
package com.threerings.orth.player.data;

import javax.annotation.Generated;

import com.threerings.orth.player.client.PlayerService;
import com.threerings.presents.client.Client;
import com.threerings.presents.data.InvocationMarshaller;

/**
 * Provides the implementation of the {@link PlayerService} interface
 * that marshalls the arguments and delivers the request to the provider
 * on the server. Also provides an implementation of the response listener
 * interfaces that marshall the response arguments and deliver them back
 * to the requesting client.
 */
@Generated(value={"com.threerings.presents.tools.GenServiceTask"},
           comments="Derived from PlayerService.java.")
public class PlayerMarshaller extends InvocationMarshaller
    implements PlayerService
{
}
