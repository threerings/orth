package com.threerings.orth.comms.data;

import com.threerings.presents.client.InvocationReceiver;

public interface CommReceiver
    extends InvocationReceiver
{
    void receiveComm (Object comm);
}
