//
// $Id$

package com.threerings.orth.chat.server;

import com.threerings.orth.aether.data.PlayerName;
import com.threerings.orth.aether.server.PlayerLocator;
import com.threerings.orth.chat.data.OrthChatCodes;
import com.threerings.orth.chat.data.SpeakObject;
import com.threerings.orth.chat.server.SpeakProvider;
import com.threerings.orth.data.OrthPlayer;
import com.threerings.orth.chat.data.Speak;
import com.threerings.presents.client.InvocationService.InvocationListener;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.server.InvocationException;

/**
 * An instance of this class is associated with every {@link SpeakObject} instance that
 * needs to have speech delivered through it. We are providers for {@link SpeakService},
 * and we post a message on the {@link DObject} that is our link back to all the clients
 * that should hear the speech.
 */
public class OrthSpeakProvider
    implements SpeakProvider
{
    public OrthSpeakProvider (SpeakObject obj, PlayerLocator locator)
    {
        _speakObj = obj;
        _locator = locator;
    }

    public void speak (ClientObject caller, String msg, InvocationListener listener)
        throws InvocationException
    {
        PlayerName name = ((OrthPlayer) caller).getPlayerName();

        // check access

        _speakObj.asDObject().postMessage(
            OrthChatCodes.SPEAK_MSG_TYPE, new Speak(name, msg));
    }

    protected SpeakObject _speakObj;
    protected PlayerLocator _locator;
}