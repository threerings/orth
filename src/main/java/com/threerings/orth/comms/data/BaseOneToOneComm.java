package com.threerings.orth.comms.data;

import com.threerings.orth.data.ModuleStreamable;
import com.threerings.orth.data.PlayerName;

public abstract class BaseOneToOneComm extends ModuleStreamable
    implements OneToOneComm
{
    public BaseOneToOneComm (PlayerName from, PlayerName to)
    {
        _from = from;
        _to = to;
    }

    @Override
    public PlayerName getTo ()
    {
        return _to;
    }

    @Override
    public PlayerName getFrom ()
    {
        return _from;
    }


    protected PlayerName _from, _to;
}
