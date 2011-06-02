package com.threerings.orth.aether.client;

import com.threerings.orth.aether.data.PlayerName;
import com.threerings.presents.client.InvocationReceiver;

public interface FriendReceiver
    extends InvocationReceiver
{
    void friendshipRequested (PlayerName source);

    void friendshipAccepted (PlayerName acceptor);
}
