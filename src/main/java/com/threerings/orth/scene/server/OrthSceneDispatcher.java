//
// $Id$
//
// Orth library - tools for developing networked games
// Copyright (C) 2002-2010 Three Rings Design, Inc., All Rights Reserved
// http://www.threerings.net/code/nenya/
//
// This library is free software; you can redistribute it and/or modify it
// under the terms of the GNU Lesser General Public License as published
// by the Free Software Foundation; either version 2.1 of the License, or
// (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

package com.threerings.orth.scene.server;

import javax.annotation.Generated;

import com.threerings.orth.scene.data.EntityIdent;
import com.threerings.orth.scene.data.OrthSceneMarshaller;
import com.threerings.presents.client.InvocationService;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.server.InvocationDispatcher;
import com.threerings.presents.server.InvocationException;
import com.threerings.whirled.spot.data.Location;

/**
 * Dispatches requests to the {@link OrthSceneProvider}.
 */
@Generated(value={"com.threerings.presents.tools.GenServiceTask"},
           comments="Derived from OrthSceneService.java.")
public class OrthSceneDispatcher extends InvocationDispatcher<OrthSceneMarshaller>
{
    /**
     * Creates a dispatcher that may be registered to dispatch invocation
     * service requests for the specified provider.
     */
    public OrthSceneDispatcher (OrthSceneProvider provider)
    {
        this.provider = provider;
    }

    @Override
    public OrthSceneMarshaller createMarshaller ()
    {
        return new OrthSceneMarshaller();
    }

    @Override
    public void dispatchRequest (
        ClientObject source, int methodId, Object[] args)
        throws InvocationException
    {
        switch (methodId) {
        case OrthSceneMarshaller.CHANGE_LOCATION:
            ((OrthSceneProvider)provider).changeLocation(
                source, (EntityIdent)args[0], (Location)args[1]
            );
            return;

        case OrthSceneMarshaller.REQUEST_CONTROL:
            ((OrthSceneProvider)provider).requestControl(
                source, (EntityIdent)args[0]
            );
            return;

        case OrthSceneMarshaller.SEND_SPRITE_MESSAGE:
            ((OrthSceneProvider)provider).sendSpriteMessage(
                source, (EntityIdent)args[0], (String)args[1], (byte[])args[2], ((Boolean)args[3]).booleanValue()
            );
            return;

        case OrthSceneMarshaller.SEND_SPRITE_SIGNAL:
            ((OrthSceneProvider)provider).sendSpriteSignal(
                source, (String)args[0], (byte[])args[1]
            );
            return;

        case OrthSceneMarshaller.SET_ACTOR_STATE:
            ((OrthSceneProvider)provider).setActorState(
                source, (EntityIdent)args[0], ((Integer)args[1]).intValue(), (String)args[2]
            );
            return;

        case OrthSceneMarshaller.UPDATE_MEMORY:
            ((OrthSceneProvider)provider).updateMemory(
                source, (EntityIdent)args[0], (String)args[1], (byte[])args[2], (InvocationService.ResultListener)args[3]
            );
            return;

        default:
            super.dispatchRequest(source, methodId, args);
            return;
        }
    }
}
